require_relative 'qr_generate_abstract'

class QrGenerateCoverage < QrGenerateAbstract
  def perform()
    results = []

    # 保険者番号レコード
    insurer_record = get_records(22)&.first
    if insurer_record.present?
      coverage = FHIR::Coverage.new
      coverage.id = SecureRandom.uuid
      coverage.status = :active

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
      organization = FHIR::Organization.new
      organization.id = SecureRandom.uuid
      organization.identifier << build_identifier(insurer_record[:insurer_number], 'urn:oid:1.2.392.100495.20.3.61')
      organization.type << build_codeable_concept('pay', 'Payer', 'http://terminology.hl7.org/CodeSystem/organization-type')
      entry = FHIR::Bundle::Entry.new
      entry.resource = organization
      @bundle.entry.concat << entry
      coverage.payor << build_reference(organization)

      # 記号番号レコード
      sym_num_record = get_records(23)&.first
      if sym_num_record.present?
        # 被保険者証記号
        if sym_num_record[:insured_symbol].present?
          extension = FHIR::Extension.new
          extension.url = build_url(:structure_definition, 'InsuredPersonSymbol')
          extension.valueString = sym_num_record[:insured_symbol]
          coverage.extension << extension
        end
        # 被保険者証記号
        if sym_num_record[:insured_number].present?
          extension = FHIR::Extension.new
          extension.url = build_url(:structure_definition, 'InsuredPersonNumber')
          extension.valueString = sym_num_record[:insured_number]
          coverage.extension << extension
        end
        # 被保険者／被扶養者
        coverage.relationship = build_codeable_concept(sym_num_record[:relationship], (sym_num_record[:relationship] == '1' ? '被保険者' : '被扶養者'), 'urn:oid:1.2.392.100495.20.2.62')
      end

      # 負担・給付率レコード
      payment_record = get_records(24)&.first
      if payment_record.present?
        cost = FHIR::Coverage::CostToBeneficiary.new
        cost.type = build_codeable_concept('copaypct', 'Copay Percentage', 'http://terminology.hl7.org/CodeSystem/coverage-copay-type')
        cost.valueQuantity = build_quantity(payment_record[:patient_payment_rate].to_i, '%', 'http://unitsofmeasure.org')

        # 患者一部負担区分レコード
        partial_payment_record = get_records(14)&.first
        if partial_payment_record.present?
            exception = FHIR::Coverage::CostToBeneficiary::Exception.new
            exception.type = case partial_payment_record[:partial_payment_class]
                             when '1','4' # 1,4:高齢者一般
                               build_codeable_concept('1', '高齢者一般', 'LC')
                             when '2' # 2:高齢者７割
                               build_codeable_concept('2', '高齢者７割', 'LC')
                             when '3' # 3:６歳未満
                               build_codeable_concept('3', '６歳未満', 'LC')
                             end
            cost.exception << exception
        end
        coverage.costToBeneficiary << cost
      end

      # Patientリソースの参照
      coverage.beneficiary = build_reference(get_resources_from_type('Patient').first)

      results << build_entry(coverage)
    end

    # 第一,第二,第三,特殊公費レコード
    get_all_records.select{|record|record[:record_number].in? %w[27 28 29 30]}.each_with_index do |public_insurance_record, idx|
      coverage = FHIR::Coverage.new
      coverage.id = SecureRandom.uuid
      coverage.status = :active
      coverage.type = build_codeable_concept('8', '公費', 'urn:oid:1.2.392.100495.20.2.61')

      # 公費負担者番号
      extension = FHIR::Extension.new
      extension.url = build_url(:code_system, 'CoverageClass')
      extension.valueString = public_insurance_record[:identification_number]
      coverage.extension << extension

      # 公費受給者番号
      coverage.subscriberId = public_insurance_record[:recipient_number]

      coverage.order = idx + 1

      # Patientリソースの参照
      coverage.beneficiary = build_reference(get_resources_from_type('Patient').first)

      results << build_entry(coverage)
    end

    # Section
    get_composition.section.first.entry.concat results.map{|entry|build_reference(entry.resource)}
    
    results
  end
end