require_relative 'orca_generate_abstract'

class OrcaGenerateMedicationRequest < OrcaGenerateAbstract
    def perform()
        section = FHIR::Composition::Section.new
        section.title = '処方指示ボディ'
        section.code = create_codeable_concept('02', '処方指示ボディ', 'TBD')

        results = []

        # 処方情報(*50)
        get_orcadata["Rp"].compact.reject(&:empty?).each_with_index do |orca_rp, rp_idx|
            medications = []
            hash = nil

            # 薬剤情報(*50)
            orca_rp["Medication"].compact.reject(&:empty?).each do |medication|
                case true
                when medication["Code"].start_with?('6') # 医薬品
                    medications << hash if hash.present?
                    hash = { medication: medication, comments: [] }
                when medication["Code"].start_with?('8') # コメント
                    hash[:comments] << medication
                end
            end
            medications << hash if hash.present?

            # 薬剤情報(*50)
            medications.each_with_index do |medication, med_idx|
                medication_request = FHIR::MedicationRequest.new
                medication_request.id = SecureRandom.uuid
                medication_request.status = :draft
                medication_request.intent = :order
                dosage = FHIR::Dosage.new
                dosage.timing = FHIR::Timing.new
                medication_request.dosageInstruction << dosage
                dispense_request = FHIR::MedicationRequest::DispenseRequest.new
                medication_request.dispenseRequest = dispense_request
                orca_medication = medication[:medication]

                # RP番号
                medication_request.identifier << create_identifier(rp_idx + 1, 'urn:oid:1.2.392.100495.20.3.81')
                # RP内連番
                medication_request.identifier << create_identifier(med_idx + 1, 'urn:oid:1.2.392.100495.20.3.xx')
                
                # 薬剤
                medication_request.medicationCodeableConcept = create_codeable_concept(
                    (orca_medication["Generic_Flg"] == '1' ? "#{orca_medication["Generic_Code"][0,9]}ZZZ" : orca_medication["Code"]),
                    orca_medication["Name"],
                    "urn:oid:1.2.392.100495.20.2.#{(orca_medication["Generic_Flg"] == '1' ? '81' : '71')}" # 71:レセプト電算コード / 81:一般名処方マスタ
                )

                # 数量(1日量)
                dose = FHIR::Dosage::DoseAndRate.new    
                ratio = FHIR::Ratio.new
                ratio.numerator = create_quantity(orca_medication["Amount"].to_f, orca_medication["Unit_Name"])
                ratio.denominator = create_quantity(1, "d")
                dose.rateRatio = ratio
                dosage.doseAndRate << dose
    
                # 日数/回数
                if orca_rp["Unit_Name"] == '日分'
                    # 日数
                    duration = FHIR::Duration.new
                    duration.value = orca_rp["Count"].to_i
                    duration.unit = 'd'
                    dispense_request.expectedSupplyDuration = duration
                else
                    # 回数
                    extension = FHIR::Extension.new
                    extension.url = "http://hl7fhir.jp/fhir/StructureDefinition/Extension-JPCore-xxx"
                    extension.valueInteger = orca_rp["Count"].to_i
                    dispense_request.extension << extension
                    # 頓用
                    dosage.asNeededBoolean = true if orca_rp["Medical_Class"] == '22'
                end

                # 調剤量
                dispense_request.quantity = create_quantity(
                    orca_medication["Amount"].to_f * orca_rp["Count"].to_i, 
                    orca_medication["Unit_Name"]
                )

                # 用法
                orca_dosage = orca_rp["Medication"].find{|medication|medication["Code"].present? && medication["Code"].start_with?('001')}
                if orca_dosage.present?
                    dosage.timing.code = create_codeable_concept(orca_dosage["Code"], orca_dosage["Name"], "LC")
                end

                # コメント
                dosage.additionalInstruction = medication[:comments].map{|comment|
                    create_codeable_concept(comment["Code"], comment["Name"], "LC")
                }

                # 変更不可欄記載フラグ
                if get_orcadata["IncludingUnchangeable_Flg"] == '1'
                    substitution = FHIR::MedicationRequest::Substitution.new
                    substitution.allowedCodeableConcept = create_codeable_concept('3', '後発品変更不可', 'urn:oid:1.2.392.100495.20.2.41')
                    medication_request.substitution = substitution
                end

                # Patientリソースの参照
                medication_request.subject = create_reference(get_resources_from_type('Patient').first.resource)
                # PractitionerRoleリソースの参照
                medication_request.requester = create_reference(get_resources_from_type('PractitionerRole').first.resource)
                
                section.entry << create_reference(medication_request)

                entry = FHIR::Bundle::Entry.new
                entry.resource = medication_request
                results << entry
            end
        end

        composition = get_composition.resource
        composition.section << section
        results
    end
end