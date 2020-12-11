require_relative 'sips_generate_abstract'

class SipsGenerateCoverage < SipsGenerateAbstract
    def perform()
        patient_record = get_records(PATIENT)&.first
        return unless patient_record.present?
        results = []

        if patient_record[:insurer_number].present?
            coverage = FHIR::Coverage.new
            coverage.id = SecureRandom.uuid
            coverage.status = :draft

            codeable_concept = FHIR::CodeableConcept.new
            coding = FHIR::Coding.new
            coding.code = patient_record[:insurance_kind]
            coding.display = case coding.code
                             when '1' then '医保'
                             when '2' then patient_record[:insurer_number][0,2] == '39' ? '後期高齢者' : '国保'
                             when '3' then '労災'
                             when '4' then '自賠'
                             when '5' then '公害'
                             when '6' then '自費'
                             when '7' then '介護'
                             end
            coding.system = 'urn:oid:1.2.392.100495.20.2.61'
            codeable_concept.coding << coding
            coverage.type = codeable_concept

            # 保険者番号
            organization = FHIR::Organization.new
            organization.id = SecureRandom.uuid
            organization.identifier << create_identifier(patient_record[:insurer_number], 'urn:oid:1.2.392.100495.20.3.61')
            organization.type << create_codeable_concept('pay', 'Payer', 'http://hl7.org/fhir/ValueSet/organization-type')
            entry = FHIR::Bundle::Entry.new
            entry.resource = organization
            @bundle.entry.concat << entry
            coverage.payor << create_reference(organization)

            # 被保険者証記号/番号
            coverage.subscriberId = "#{patient_record[:insured_symbol]} #{patient_record[:insured_number]}"
            # 被保険者／被扶養者
            coverage.relationship = create_codeable_concept(patient_record[:relationship], (patient_record[:relationship] == '1' ? '被保険者' : '被扶養者'), 'urn:oid:1.2.392.100495.20.2.62')

            cost = FHIR::Coverage::CostToBeneficiary.new
            cost.type = create_codeable_concept('copaypct', 'Copay Percentage', 'http://hl7.org/fhir/ValueSet/coverage-copay-type')
            cost.valueQuantity = create_quantity(patient_record[:patient_payment_rate].to_i, '%') if patient_record[:patient_payment_rate].present?

            if patient_record[:copay_amount_class].to_i.positive?
                exception = FHIR::Coverage::CostToBeneficiary::Exception.new
                exception.type = case patient_record[:copay_amount_class]
                                    when '1' # 1:高齢者一般
                                        create_codeable_concept('1', '高齢者一般', 'LC')
                                    when '4' # 4:高齢者７割
                                        create_codeable_concept('2', '高齢者７割', 'LC')
                                    when '3' # 3:６歳未満
                                        create_codeable_concept('3', '６歳未満', 'LC')
                                    end
                cost.exception << exception
            end
            coverage.costToBeneficiary << cost

            entry = FHIR::Bundle::Entry.new
            entry.resource = coverage
            results << entry
        end

        # 第一, 第二, 第三, 特殊公費
        public_insurances = [
            { insure_number: patient_record[:public_insurer_number1], insured_person_number: patient_record[:public_insured_person_number1] },
            { insure_number: patient_record[:public_insurer_number2], insured_person_number: patient_record[:public_insured_person_number2] },
            { insure_number: patient_record[:public_insurer_number3], insured_person_number: patient_record[:public_insured_person_number3] },
            { insure_number: patient_record[:special_insurer_number], insured_person_number: patient_record[:special_insured_person_number] },
        ].compact.reject{|c|c[:insure_number].blank?}

        public_insurances.each_with_index do |public_insurance_record, idx|
            coverage = FHIR::Coverage.new
            coverage.id = SecureRandom.uuid
            coverage.status = :draft
            coverage.type = create_codeable_concept('8', '公費', 'urn:oid:1.2.392.100495.20.2.61')

            # 公費負担者番号
            extension = FHIR::Extension.new
            extension.url = "http://hl7fhir.jp/fhir/StructureDefinition/Extension-JPCore-xxx"
            extension.valueString = public_insurance_record[:insure_number]
            coverage.extension << extension

            # 公費受給者番号
            coverage.subscriberId = public_insurance_record[:insured_person_number]

            coverage.order = idx + 1

            entry = FHIR::Bundle::Entry.new
            entry.resource = coverage
            results << entry
        end

        get_composition.section.first.entry.concat results.map{|entry|create_reference(entry.resource)}
        results
    end
end