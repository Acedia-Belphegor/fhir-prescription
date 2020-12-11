require_relative 'cda_generate_abstract'

class CdaGenerateMedicationDispense < CdaGenerateAbstract
    def perform()
        component = get_clinical_document.xpath('component/structuredBody/component').find{ |c| 
            c.xpath("section/code/@code").text == '02' && 
            c.xpath("section/code/@codeSystem").text == '1.2.392.100495.20.2.12' 
        }
        return unless component.present?
        results = []

        section = FHIR::Composition::Section.new
        section.title = component.xpath('section/title').text
        section.code = generate_codeable_concept(component.xpath('section/code'))
        section.text = component.xpath('section/text/list/item').map{ |item| item.text }.join('\n')

        component.xpath('section/entry').each do |entry|
            medication_dispense = FHIR::MedicationDispense.new
            medication_dispense.id = SecureRandom.uuid
            medication_dispense.status = :unknown
            dosage = FHIR::Dosage.new
            dosage.timing = FHIR::Timing.new
            medication_dispense.dosageInstruction << dosage

            # 調剤結果ID
            medication_dispense.identifier << generate_identifier(get_clinical_document.xpath('id'))

            # 薬剤師・薬局情報
            author = get_clinical_document.xpath('author')
            if author.present?
                # 調剤結果発行年月日
                medication_dispense.whenHandedOver = author.xpath('time/@value').text
            end

            # 医薬品ごとの調剤実施内容
            supply = entry.xpath('supply')

            # 服用順序
            id = supply.xpath('id').find{ |id| id.xpath('@root').text == '1.2.392.100495.20.3.82' }
            if id.present?
                dosage.sequence = id.xpath('@extension').to_i
            end

            # 剤型
            medication_dispense.category = generate_codeable_concept(supply.xpath('code'))

            # 投与日数／投与回数
            effective_time = supply.xpath('effectiveTime').find{ |et| et.xpath('@operator').blank? }
            if effective_time.present?
                timing_repeat = FHIR::Timing::Repeat.new
                if effective_time.xpath('width/@unit').text == 'd'
                    # 日数
                    timing_repeat.duration = effective_time.xpath('width/@value').text.to_i
                    timing_repeat.durationUnit = 'd'

                    quantity = FHIR::Quantity.new
                    quantity.value = timing_repeat.duration
                    quantity.unit = timing_repeat.durationUnit
                    medication_dispense.daysSupply = quantity
                else
                    # 回数
                    timing_repeat.count = effective_time.xpath('width/@value').text.to_i
                end
                dosage.timing.repeat = timing_repeat
            end

            # 用法
            effective_time = supply.xpath('effectiveTime').find{ |et| et.xpath('@operator').text == 'A' }
            if effective_time.present?
                dosage.timing.code = generate_codeable_concept(effective_time.xpath('event'))
                dosage.text = effective_time.xpath('event/originalText').text
            end

            # 用法補足
            supply.xpath('effectiveTime').select{ |et| et.xpath('@operator').text == 'I' }.each do |effective_time|
                dosage.additionalInstruction << generate_codeable_concept(effective_time.xpath('event'))
                doosage.patientInstruction ||= effective_time.xpath('originalText').text
            end

            # 調剤数量
            if supply.xpath('quantity').present?
                medication_dispense.quantity = generate_quantity(supply.xpath('quantity'))
            end

            # 医薬品補足情報2: 特定の医薬品の補足情報
            entry_relationship = supply.xpath('entryRelationship').find{ |er| er.xpath('@typeCode').text == 'COMP' }
            if entry_relationship.present?
                annotation = FHIR::Annotation.new
                annotation.text = entry_relationship.xpath('supply/text').text
                medication_dispense.note << annotation
            end

            # 医薬品名
            manufactured_product = supply.xpath('product/manufacturedProduct')
            medication_dispense.medicationCodeableConcept = generate_codeable_concept(manufactured_product.xpath('manufacturedLabeledDrug/code'))

            # 調剤の元となった電子処方箋の処方箋ID
            reference = FHIR::Reference.new
            reference.type = 'MedicationRequest'
            reference.id = 'dummy' # ダミー値
            medication_dispense.authorizingPrescription << reference

            # 医薬品の変更有無
            substitution = FHIR::MedicationDispense::Substitution.new
            substitution.wasSubstituted = false
            substitution.type = create_codeable_concept('N','none','http://terminology.hl7.org/ValueSet/v3-ActSubstanceAdminSubstitutionCode')
            medication_dispense.substitution = substitution

            # Patientリソースの参照
            medication_dispense.subject = create_reference(get_resources_from_type('Patient').first)

            # PractitionerRoleリソースの参照
            performer = FHIR::MedicationDispense::Performer.new
            performer.function = create_codeable_concept('finalchecker','Final Checker','http://terminology.hl7.org/CodeSystem/medicationdispense-performer-function')
            performer.actor = create_reference(get_resources_from_type('PractitionerRole').first)
            medication_dispense.performer << performer

            section.entry << create_reference(medication_dispense)

            entry = FHIR::Bundle::Entry.new
            entry.resource = medication_dispense
            results << entry
        end

        composition = get_composition
        composition.section << section
        results
    end
end