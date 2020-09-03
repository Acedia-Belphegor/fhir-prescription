require_relative 'cda_generate_abstract'

class CdaGenerateMedicationRequest < CdaGenerateAbstract
    def perform()
        component = get_clinical_document.xpath('component/structuredBody/component').find{ |c| 
            c.xpath("section/code/@code").text == '01' && 
            c.xpath("section/code/@codeSystem").text == '1.2.392.100495.20.2.12' 
        }
        return unless component.present?
        results = []
        sequence = {}

        section = FHIR::Composition::Section.new
        section.title = component.xpath('section/title').text
        section.code = generate_codeable_concept(component.xpath('section/code'))
        section.text = component.xpath('section/text/list/item').map{ |item| item.text }.join('\n')

        component.xpath('section/entry').each do |entry|
            medication_request = FHIR::MedicationRequest.new
            medication_request.id = SecureRandom.uuid
            medication_request.status = :draft
            medication_request.intent = :order
            dosage = FHIR::Dosage.new
            dosage.timing = FHIR::Timing.new
            medication_request.dosageInstruction << dosage
            dispense_request = FHIR::MedicationRequest::DispenseRequest.new
            medication_request.dispenseRequest = dispense_request

            # 処方箋ID
            medication_request.identifier << generate_identifier(get_clinical_document.xpath('id'))

            # 薬剤ごとの処方指示情報
            sbadm = entry.xpath('substanceAdministration')

            # RP番号
            id = sbadm.xpath('id').find{ |id| id.xpath('@root').text == '1.2.392.100495.20.3.81' }
            if id.present?
                medication_request.identifier << generate_identifier(id)

                # RP内連番
                rp = id.xpath('@extension').text.to_i
                sequence[rp] ||= 0
                sequence[rp] += 1
                medication_request.identifier << create_identifier(sequence[rp].to_s, '1.2.392.100495.20.3.XX')
            end

            # 服用順序
            id = sbadm.xpath('id').find{ |id| id.xpath('@root').text == '1.2.392.100495.20.3.82' }
            if id.present?
                dosage.sequence = id.xpath('@extension').to_i
            end

            # 剤型
            if sbadm.xpath('code').present?
                medication_request.category << generate_codeable_concept(sbadm.xpath('code'))

                # 頓服
                if sbadm.xpath('code/@code').text == '2'
                    dosage.asNeededBoolean = true 
                end
            end

            # 医薬品名
            manufactured_product = sbadm.xpath('consumable/manufacturedProduct')

            if manufactured_product.xpath('manufacturedLabeledDrug').present?
                # 薬品名
                medication_request.medicationCodeableConcept = generate_codeable_concept(manufactured_product.xpath('manufacturedLabeledDrug/code'))
            elsif manufactured_product.xpath('manufacturedMaterial').present?
                # 一般名
                medication_request.medicationCodeableConcept = generate_codeable_concept(manufactured_product.xpath('manufacturedMaterial/code'))
            end

            # 用法
            effective_time = sbadm.xpath('effectiveTime').find{ |et| et.xpath('@operator').text == 'A' }
            if effective_time.present?
                dosage.timing.code = generate_codeable_concept(effective_time.xpath('event'))
                dosage.text = effective_time.xpath('event/originalText').text
            end

            # 用法補足
            sbadm.xpath('effectiveTime').select{ |et| et.xpath('@operator').text == 'I' }.each do |effective_time|
                dosage.additionalInstruction << generate_codeable_concept(effective_time.xpath('event'))
                doosage.patientInstruction ||= effective_time.xpath('originalText').text
            end

            # 投与日数／投与回数
            effective_time = sbadm.xpath('effectiveTime').find{ |et| et.xpath('@operator').blank? }
            if effective_time.present?
                timing_repeat = FHIR::Timing::Repeat.new
                if effective_time.xpath('width/@unit').text == 'd'
                    # 日数
                    duration = FHIR::Duration.new
                    duration.value = effective_time.xpath('width/@value').text.to_i
                    duration.unit = 'd'
                    dispense_request.expectedSupplyDuration = duration
                else
                    # 回数
                    extension = FHIR::Extension.new
                    extension.url = "http://hl7fhir.jp/fhir/StructureDefinition/Extension-JPCore-xxx"
                    extension.valueInteger = effective_time.xpath('width/@value').text.to_i
                    dispense_request.extension << extension
                end
                dosage.timing.repeat = timing_repeat
            end

            # 部位
            if sbadm.xpath('approachSiteCode').present?
                dosage.site = generate_codeable_concept(sbadm.xpath('approachSiteCode').first)
            end

            dose = FHIR::Dosage::DoseAndRate.new
            # 一回量
            if sbadm.xpath('doseQuantity').present?
                dose.doseQuantity = generate_quantity(sbadm.xpath('doseQuantity'))
                # 力価区分
                dose.type = generate_codeable_concept(sbadm.xpath('doseCheckQuantity/numerator/translation'))
            end
            
            # 一日量
            if sbadm.xpath('doseCheckQuantity').present?
                ratio = FHIR::Ratio.new
                ratio.numerator = generate_quantity(sbadm.xpath('doseCheckQuantity/numerator'))
                ratio.denominator = generate_quantity(sbadm.xpath('doseCheckQuantity/denominator'))
                dose.rateRatio = ratio
            end
            dosage.doseAndRate << dose

            # 薬品補足情報
            if sbadm.xpath('entryRelationship').present?
                # 総投与量
                dispense_request.quantity = generate_quantity(sbadm.xpath('entryRelationship/supply/quantity'))

                # 後発品変更不可コード
                substitution = FHIR::MedicationRequest::Substitution.new
                substitution.allowedCodeableConcept = generate_codeable_concept(sbadm.xpath('entryRelationship/supply/code'))
                medication_request.substitution = substitution

                # 調剤補足情報
                if sbadm.xpath('entryRelationship/supply/text').present?
                    extension = FHIR::Extension.new
                    extension.url = "http://hl7fhir.jp/fhir/StructureDefinition/Extension-JPCore-DispenseInstruction"
                    codeable_concept = FHIR::CodeableConcept.new
                    codeable_concept.text = sbadm.xpath('entryRelationship/supply/text').text
                    extension.valueCodeableConcept = codeable_concept
                    dispense_request.extension = extension
                end
            end

            # Patientリソースの参照
            medication_request.subject = create_reference(get_resources_from_type('Patient').first.resource)
            # PractitionerRoleリソースの参照
            medication_request.requester = create_reference(get_resources_from_type('PractitionerRole').first.resource)
            # Coverageリソースの参照
            medication_request.insurance = get_resources_from_type('Coverage').map{ |coverage| create_reference(coverage.resource) }

            section.entry << create_reference(medication_request)

            entry = FHIR::Bundle::Entry.new
            entry.resource = medication_request
            results << entry
        end

        composition = get_composition.resource
        composition.section << section
        results
    end
end