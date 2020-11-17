require_relative 'orca_generate_abstract'

class OrcaGenerateCoverage < OrcaGenerateAbstract

    # ORCA/保険の種類(InsuranceProvider_Class) => 保険種別
    INSURANCE_KIND_MAPPING = {
        "001" => "1", # 政府管掌
        "002" => "1", # 船員保険
        "003" => "1", # 一般療養
        "004" => "1", # 特別療養
        "006" => "1", # 組合健保
        "007" => "1", # 自衛官等保険
        "009" => "1", # 協会けんぽ
        "010" => "8", # 感染症（３７条の２）
        "011" => "8", # 感染症（結核入院）
        "012" => "8", # 生活保護
        "013" => "8", # 戦傷病者（療養給付）
        "014" => "8", # 戦傷病者（更正）
        "015" => "8", # 自立支援医療（更生）
        "016" => "8", # 自立支援医療（育成）
        "017" => "8", # 児童福祉（療養医療）
        "018" => "8", # 原爆認定疾病
        "019" => "8", # 原爆一般疾病
        "020" => "8", # 精神措置入院
        "021" => "8", # 自立支援医療（精神通院）
        "023" => "8", # 母子家庭
        "024" => "8", # 療養介護医療
        "025" => "8", # 中国残留邦人等支援
        "027" => "8", # 老人保険
        "028" => "8", # 感染症（１類・２類）
        "029" => "8", # 新感染症
        "030" => "8", # 心神喪失者等医療
        "031" => "1", # 国家公務員共済組合
        "032" => "1", # 地方公務員共済組合
        "033" => "1", # 警察共済組合
        "034" => "1", # 公立・私立学校共済
        "038" => "8", # 肝炎治療特別促進事業医療
        "039" => "7", # 後期高齢者医療
        "040" => "7", # 後期高齢者医療特別療養費
        "051" => "8", # 特定疾患（負担有り）
        "052" => "8", # 小児慢性特定疾病医療
        "053" => "8", # 児童保護措置
        "054" => "8", # 難病医療
        "060" => "2", # 国民健康保険
        "062" => "8", # 特定Ｂ型肝炎ウイルス感染者医療
        "063" => "1", # 特例退職（組合健保）
        "066" => "8", # 石綿健康被害救済
        "067" => "2", # 退職者医療（国保）
        "068" => "1", # 特別療養費
        "069" => "1", # 退職特別療養費
        "072" => "1", # 特例退職（国家公務員）
        "073" => "1", # 特例退職（地方公務員）
        "074" => "1", # 特例退職（警察）
        "075" => "1", # 特例退職（学校）
        "079" => "8", # 障害児施設医療
        "091" => "8", # 特定疾患（負担無し）
        "971" => "3", # 労災保険
        "973" => "4", # 自賠責保険
        "975" => "5", # 公害保険
        "980" => "6", # 自費
    }

    def perform()
        # 保険組合せ情報
        orca_insurance = get_orcadata["Insurance_Combination_Information"]
        return unless orca_insurance.present?
        results = []

        if orca_insurance["InsuranceProvider_Class"].present?
            coverage = FHIR::Coverage.new
            coverage.id = SecureRandom.uuid
            coverage.status = :draft

            codeable_concept = FHIR::CodeableConcept.new
            coding = FHIR::Coding.new
            coding.code = INSURANCE_KIND_MAPPING[orca_insurance["InsuranceProvider_Class"]]
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

            # 保険情報
            orca_healthinsurance = orca_insurance["HealthInsurance_Information"]

            # 保険者番号
            organization = FHIR::Organization.new
            organization.id = SecureRandom.uuid
            organization.identifier << create_identifier(orca_healthinsurance["InsuranceProvider_Number"], 'urn:oid:1.2.392.100495.20.3.61')
            organization.type << create_codeable_concept('pay', 'Payer', 'http://hl7.org/fhir/ValueSet/organization-type')
            entry = FHIR::Bundle::Entry.new
            entry.resource = organization
            @bundle.entry.concat << entry
            coverage.payor << create_reference(organization)

            # 記号/番号
            coverage.subscriberId = "#{orca_healthinsurance["HealthInsuredPerson_Symbol"]} #{orca_healthinsurance["HealthInsuredPerson_Number"]}".strip
            
            # 枝番
            coverage.dependent = orca_healthinsurance["HealthInsuredPerson_Branch_Number"]

            # 本人家族区分
            coverage.relationship = create_codeable_concept(
                orca_healthinsurance["RelationToInsuredPerson"], 
                (orca_healthinsurance["RelationToInsuredPerson"] == '1' ? '被保険者' : '被扶養者'), 
                'urn:oid:1.2.392.100495.20.2.62'
            )

            cost = FHIR::Coverage::CostToBeneficiary.new
            cost.type = create_codeable_concept('copaypct', 'Copay Percentage', 'http://hl7.org/fhir/ValueSet/coverage-copay-type')
            cost.valueQuantity = create_quantity(orca_insurance["HealthInsuredPerson_Rate"].to_i, '%')

            if orca_insurance["Partial_Cost_Payment_Class"].present?
                exception = FHIR::Coverage::CostToBeneficiary::Exception.new
                exception.type = case orca_insurance["Partial_Cost_Payment_Class"]
                                    when '1' # 1:高齢者一般
                                        create_codeable_concept('1', '高齢者一般', 'LC')
                                    when '2' # 2:高齢者７割
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

        # 公費情報(*4)
        orca_publicinsurances = orca_insurance["PublicInsurance_Information"].compact.reject(&:empty?)

        orca_publicinsurances.each_with_index do |orca_publicinsurance, idx|
            coverage = FHIR::Coverage.new
            coverage.id = SecureRandom.uuid
            coverage.status = :draft
            coverage.type = create_codeable_concept('8', '公費', 'urn:oid:1.2.392.100495.20.2.61')

            # 公費負担者番号
            extension = FHIR::Extension.new
            extension.url = "http://hl7fhir.jp/fhir/StructureDefinition/Extension-JPCore-xxx"
            extension.valueString = orca_publicinsurance["PublicInsurer_Number"]
            coverage.extension << extension

            # 公費受給者番号
            coverage.subscriberId = orca_publicinsurance["PublicInsuredPerson_Number"]

            coverage.order = idx + 1

            entry = FHIR::Bundle::Entry.new
            entry.resource = coverage
            results << entry
        end

        get_composition.resource.section.first.entry.concat results.map{|entry|create_reference(entry.resource)}
        results
    end
end