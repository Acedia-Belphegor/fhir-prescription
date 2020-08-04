require_relative 'qr_generate_abstract'

class QrGenerateCoverage < QrGenerateAbstract
    def perform()
        section = FHIR::Composition::Section.new
        section.title = '保険・公費情報'
        section.code = create_codeable_concept('11', '保険・公費情報', 'urn:oid:1.2.392.100495.20.2.12')

        results = []

        # 保険者番号レコード
        insurer_record = get_records(22)&.first
        if insurer_record.present?
            coverage = FHIR::Coverage.new
            coverage.id = SecureRandom.uuid
            coverage.status = :draft

            # 保険種別レコード
            insurance_kind_record = get_records(21)&.first
            if insurance_kind_record.present?
                codeable_concept = FHIR::CodeableConcept.new
                coding = FHIR::Coding.new
                coding.code = insurance_kind_record[:insurance_kind]
                coding.display = case coding.code
                                 when '1' then '医保'
                                 when '2' then '国保'
                                 when '3' then '労災'
                                 when '4' then '自賠'
                                 when '5' then '公害'
                                 when '6' then '自費'
                                 when '7' then '後期高齢者'
                                 end
                coding.system = 'urn:oid:1.2.392.100495.20.2.61'
                codeable_concept.coding << coding
                coverage.type = codeable_concept
            end

            # 保険者番号
            coverage.identifier << generate_identifier(insurer_record[:insurer_number], 'urn:oid:1.2.392.100495.20.3.61')

            # 記号番号レコード
            sym_num_record = get_records(23)&.first
            if sym_num_record.present?
                # 被保険者証記号
                coverage.identifier << generate_identifier(sym_num_record[:insured_symbol], 'urn:oid:1.2.392.100495.20.3.62')
                # 被保険者証番号
                coverage.identifier << generate_identifier(sym_num_record[:insured_number], 'urn:oid:1.2.392.100495.20.3.63')
                # 被保険者／被扶養者
                coverage.relationship = create_codeable_concept(sym_num_record[:relationship], (sym_num_record[:relationship] == '1' ? '被保険者' : '被扶養者'), 'urn:oid:1.2.392.100495.20.2.62')
            end

            # 負担・給付率レコード
            payment_record = get_records(24)&.first
            if payment_record.present?
                cost = FHIR::Coverage::CostToBeneficiary.new
                cost.type = create_codeable_concept('copaypct', 'Copay Percentage', 'http://hl7.org/fhir/ValueSet/coverage-copay-type')
                cost.valueQuantity = create_quantity(payment_record[:patient_payment_rate].to_i, '%')
                coverage.costToBeneficiary << cost
            end

            section.entry << create_reference(coverage)

            entry = FHIR::Bundle::Entry.new
            entry.resource = coverage
            results << entry
        end

        # 第一,第二,第三,特殊公費レコード
        get_all_records.select{|record|record[:record_number].in? %w[27 28 29 30]}.each do |public_insurance_record|
            coverage = FHIR::Coverage.new
            coverage.id = SecureRandom.uuid
            coverage.status = :draft
            coverage.type = create_codeable_concept('8', '公費', 'urn:oid:1.2.392.100495.20.2.61')

            # 公費負担者番号
            coverage.identifier << generate_identifier(public_insurance_record[:identification_number], 'urn:oid:1.2.392.100495.20.3.71')
            # 公費受給者番号
            coverage.identifier << generate_identifier(public_insurance_record[:recipient_number], 'urn:oid:1.2.392.100495.20.3.72')

            section.entry << create_reference(coverage)

            entry = FHIR::Bundle::Entry.new
            entry.resource = coverage
            results << entry
        end

        composition = get_composition.resource
        composition.section << section
        results
    end
end