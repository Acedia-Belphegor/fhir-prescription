require_relative 'qr_generate_abstract'

class QrGenerateMedicationRequest < QrGenerateAbstract
    def perform()
        section = FHIR::Composition::Section.new
        section.title = '処方指示ボディ'
        section.code = create_codeable_concept('02', '処方指示ボディ', 'TBD')

        results = []

        get_records(201).each do |medication_record|
            medication_request = FHIR::MedicationRequest.new
            medication_request.id = SecureRandom.uuid
            medication_request.status = :draft
            medication_request.intent = :order
            dosage = FHIR::Dosage.new
            dosage.timing = FHIR::Timing.new
            medication_request.dosageInstruction << dosage
            dispense_request = FHIR::MedicationRequest::DispenseRequest.new
            medication_request.dispenseRequest = dispense_request

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

            # RP番号
            medication_request.identifier << generate_identifier(medication_record[:rp_number].to_i, 'urn:oid:1.2.392.100495.20.3.81')

            # RP内連番
            medication_request.identifier << generate_identifier(medication_record[:rp_branch_number].to_i, 'urn:oid:1.2.392.100495.20.3.xx')

            # 薬品
            codeable_concept = FHIR::CodeableConcept.new
            coding = FHIR::Coding.new
            # 薬品コード
            coding.code = medication_record[:medication_code]
            # 薬品名称
            coding.display = if medication_record[:medication_code_kind] == '2' && medication_record[:medication_name].blank?
                # レセプト電算コードの場合は薬品名称が省略可能であるため、省略されている場合は医薬品マスターから名称を取得する
                master = get_receipt_medication_master.find{|master|master[:medication_code] == medication_record[:medication_code]}
                master[:medication_name] if master.present?
            else                
                medication_record[:medication_name]
            end
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

            dose = FHIR::Dosage::DoseAndRate.new
            # １回服用量レコード
            one_time_dose_record = get_records(241)&.find{|r|
                r[:rp_number] == medication_record[:rp_number] &&
                r[:rp_branch_number] == medication_record[:rp_branch_number]
            }
            if one_time_dose_record.present?
                dose.doseQuantity = create_quantity(one_time_dose_record[:one_time_dose_quantity].to_f, medication_record[:unit_name])
            end

            # 用量(1日量)
            ratio = FHIR::Ratio.new
            ratio.numerator = create_quantity(medication_record[:dose_quantity].to_f, medication_record[:unit_name])
            ratio.denominator = create_quantity(1, "d")
            dose.rateRatio = ratio
            dosage.doseAndRate << dose

            # 投与日数/回数
            if form_record[:dosage_form_class] == '1'
                # 日数
                duration = FHIR::Duration.new
                duration.value = form_record[:dispensing_quantity].to_i
                duration.unit = 'd'
                dispense_request.expectedSupplyDuration = duration
            else
                # 回数
                extension = FHIR::Extension.new
                extension.url = "http://hl7fhir.jp/fhir/StructureDefinition/Extension-JPCore-xxx"
                extension.valueInteger = form_record[:dispensing_quantity].to_i
                dispense_request.extension << extension
                # 頓用
                dosage.asNeededBoolean = true if form_record[:dosage_form_class] == '2'
            end

            # 調剤量
            dispense_request.quantity = create_quantity(
                medication_record[:dose_quantity].to_f * form_record[:dispensing_quantity].to_i, 
                medication_record[:unit_name]
            )

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
            
            # １日回数
            if dosage_record[:number_of_times_per_day].to_i.positive?
                timing_repeat = FHIR::Timing::Repeat.new
                timing_repeat.frequency = dosage_record[:number_of_times_per_day].to_i
                timing_repeat.period = 1
                timing_repeat.periodUnit = 'd'
                dosage.timing.repeat = timing_repeat
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
                    # 後発医薬品関連
                    codeable_concept = FHIR::CodeableConcept.new
                    if record[:medication_supplement_class] == '6'
                        codeable_concept.coding << create_coding('4','剤形変更不可',"urn:oid:1.2.392.100495.20.2.41")
                        codeable_concept.coding << create_coding('5','含量規格変更不可',"urn:oid:1.2.392.100495.20.2.41")
                        codeable_concept.text = '剤形変更不可及び含量規格変更不可'
                    else
                        codeable_concept.coding << create_coding(
                            case record[:medication_supplement_class]
                            when '3' then '1'
                            when '4' then '2'
                            when '5' then '3'
                            end,
                            case record[:medication_supplement_class]
                            when '3' then '後発品変更不可'
                            when '4' then '剤形変更不可'
                            when '5' then '含量規格変更不可'
                            end,
                            "urn:oid:1.2.392.100495.20.2.41"
                        )
                    end
                    substitution = FHIR::MedicationRequest::Substitution.new
                    substitution.allowedCodeableConcept = codeable_concept
                    medication_request.substitution ||= substitution
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