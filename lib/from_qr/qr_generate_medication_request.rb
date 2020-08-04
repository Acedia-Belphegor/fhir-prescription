require_relative 'qr_generate_abstract'

class QrGenerateMedicationRequest < QrGenerateAbstract
    def perform()
        section = FHIR::Composition::Section.new
        section.title = '処方指示'
        section.code = create_codeable_concept('01', '処方指示', 'urn:oid:1.2.392.100495.20.2.12')

        results = []

        get_records(201).each do |medication_record|
            medication_request = FHIR::MedicationRequest.new
            medication_request.id = SecureRandom.uuid
            medication_request.status = :draft
            medication_request.intent = :order
            dosage = FHIR::Dosage.new
            dosage.timing = FHIR::Timing.new
            medication_request.dosageInstruction << dosage

            # 剤形レコード
            form_record = get_records(101).find{|r|r[:rp_number] == medication_record[:rp_number]}
            next unless form_record.present?

            # 用法レコード
            dosage_record = get_records(111).find{|r|r[:rp_number] == medication_record[:rp_number]}
            next unless dosage_record.present?
           
            # 処方箋番号レコード
            prescription_number_record = get_records(82)
            if prescription_number_record.present?
                medication_request.identifier << generate_identifier(prescription_number_record[:prescription_number], 'urn:oid:1.2.392.100495.20.3.11')
            end

            # 処方箋交付年月日レコード
            delivery_record = get_records(51)&.first
            if delivery_record.present?
                medication_request.authoredOn = Date.parse(delivery_record[:delivery_date])
            end

            # RP番号
            medication_request.groupIdentifier = generate_identifier(medication_record[:rp_number].to_i, 'urn:oid:1.2.392.100495.20.3.81')

            # 薬品
            codeable_concept = FHIR::CodeableConcept.new
            coding = FHIR::Coding.new
            coding.code = medication_record[:medication_code] # 薬品コード
            coding.display = medication_record[:medication_name] # 薬品名称
            coding.system = case medication_record[:medication_code_kind]
                            when '2' then 'urn:oid:1.2.392.100495.20.2.71' # レセプト電算コード
                            when '3' then 'urn:oid:1.2.392.100495.20.2.72' # 薬価基準収載医薬品コード
                            when '4' then 'urn:oid:1.2.392.100495.20.2.73' # YJ コード（個別医薬品コード）
                            when '6' then 'urn:oid:1.2.392.100495.20.2.74' # HOT コード（9桁）
                            when '7' then 'urn:oid:1.2.392.100495.20.2.81' # 一般名処方マスタ
                            end
            codeable_concept.coding << coding                
            medication_request.medicationCodeableConcept = codeable_concept

            # 剤形
            medication_request.category << create_codeable_concept(
                form_record[:dosage_form_class], 
                case form_record[:dosage_form_class]
                when '1' then '内服'
                when '2' then '頓服'
                when '3' then '外用'
                when '4' then '内服滴剤'
                when '5' then '注射'
                when '6' then '医療材料'
                when '9' then form_record[:dosage_form_name]
                end
            )

            # 用量(1日量)
            extension = FHIR::Extension.new
            extension.url = "http://hl7fhir.jp/fhir/StructureDefinition/Extension-JPCore-TotalDailyDose"
            extension.valueQuantity = create_quantity(medication_record[:dose_quantity].to_f, medication_record[:unit_name])
            dosage.extension << extension

            # 投与日数/回数
            timing_repeat = FHIR::Timing::Repeat.new
            if form_record[:dosage_form_class] == '1'
                # 日数
                timing_repeat.duration = form_record[:dispensing_quantity].to_i
                timing_repeat.durationUnit = 'd'
            else
                # 回数
                timing_repeat.count = form_record[:dispensing_quantity].to_i
                # 頓用
                dosage.asNeededBoolean = true if form_record[:dosage_form_class] == '2'
            end
            dosage.timing.repeat = timing_repeat

            # 調剤量
            dispense_request = FHIR::MedicationRequest::DispenseRequest.new
            dispense_request.quantity = create_quantity(
                medication_record[:dose_quantity].to_f * form_record[:dispensing_quantity].to_i, 
                medication_record[:unit_name]
            )
            medication_request.dispenseRequest = dispense_request

            # 用法
            if dosage_record[:dosage_code_kind] == '1'
                dosage.text = dosage_record[:dosage_name]
            else
                dosage.timing.code = create_codeable_concept(
                    dosage_record[:dosage_code],
                    dosage_record[:dosage_name],
                    dosage_record[:dosage_code_kind] == '2' ? 'urn:oid:1.2.392.100495.20.2.31' : nil # 2:JAMI用法コード
                )
            end
            
            # 用法補足レコード
            get_records(181).select{|record|record[:rp_number] == medication_record[:rp_number]}.each{|record|
                if supplement_record[:dosage_supplement_class].in? %w[6 9]
                    # 部位
                    dosage.site ||= create_codeable_concept(
                        record[:site_code], 
                        record[:medication_supplement_information],
                        record[:dosage_supplement_class] == '9' ? 'urn:oid:1.2.392.100495.20.2.33' : nil # 9:JAMI部位コード
                    )
                else
                    # 補足用法
                    dosage.additionalInstruction << create_codeable_concept(
                        record[:dosage_supplement_code], 
                        record[:medication_supplement_information],
                        record[:dosage_supplement_class] == '8' ? 'urn:oid:1.2.392.100495.20.2.32' : nil # 8:JAMI補足用法コード
                    )
                end
            }

            # 薬品補足レコード
            get_records(281).select{|record|
                record[:rp_number] == medication_record[:rp_number] &&
                record[:rp_branch_number] == medication_record[:rp_branch_number]
            }.each{|record|
                if record[:medication_supplement_class].in? %w[3 4 5 6]
                    # # 後発医薬品関連
                    # substitution = FHIR::MedicationRequest::Substitution.new
                    # substitution.allowedCodeableConcept = create_codeable_concept(

                    # )
                    # medication_request.substitution ||= substitution
                elsif record[:medication_supplement_class] == '7' # 7:JAMI補足用法コード
                    # 補足用法
                    dosage.additionalInstruction << create_codeable_concept(
                        record[:dosage_supplement_code], 
                        record[:medication_supplement_information],
                        'urn:oid:1.2.392.100495.20.2.32'
                    )
                else
                    dosage.additionalInstruction << create_codeable_concept(
                        record[:medication_supplement_class], 
                        record[:medication_supplement_information]
                    )
                end
            }

            # １回服用量レコード
            one_time_dose_record = get_records(241)&.find{|r|
                r[:rp_number] == medication_record[:rp_number] &&
                r[:rp_branch_number] == medication_record[:rp_branch_number]
            }
            if one_time_dose_record.present?
                dose = FHIR::Dosage::DoseAndRate.new
                dose.doseQuantity = create_quantity(one_time_dose_record[:one_time_dose_quantity].to_f, medication_record[:unit_name])
                dosage.doseAndRate << dose
            end

            # # 不均等投与
            # imbalances = dosage.additionalInstruction.map{|element|element.coding.select{|element|element.code.match(/^V[1-9][0-9.N]+$/) && element.system == 'JAMISDP01'}}.compact.reject(&:empty?)
            # if imbalances.count.positive?
            #     imbalance_doses = []
            #     imbalances.each do |imbalance|
            #         quantity = FHIR::Quantity.new
            #         quantity.value = imbalance.first.code.slice(2..-1).delete('N').to_i
            #         quantity.code = dosage.doseAndRate.first.doseQuantity.code
            #         quantity.unit = dosage.doseAndRate.first.doseQuantity.unit
            #         dose = FHIR::Dosage::DoseAndRate.new
            #         dose.type = imbalance
            #         dose.doseQuantity = quantity
            #         imbalance_doses << dose
            #     end
            #     dosage.doseAndRate = imbalance_doses
            #     dosage.additionalInstruction.delete_if{ |c| imbalances.include?(c.coding) }
            # end

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