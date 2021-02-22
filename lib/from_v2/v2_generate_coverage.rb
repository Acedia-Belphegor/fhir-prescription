require_relative 'v2_generate_abstract'

class V2GenerateCoverage < V2GenerateAbstract
    def perform()
        in1_segments = get_segments('IN1')
        return [] unless in1_segments.present?
        results = []

        in1_segments.each do |in1_segment|
            coverage = FHIR::Coverage.new
            coverage.id = SecureRandom.uuid
            coverage.status = :active

            # IN1-2.保険プランID(法制コード)
            insurance_type = get_insurance_type(in1_segment[:insurance_plan_id].first[:identifier])
            coverage.type = create_codeable_concept(insurance_type[:code], insurance_type[:name], 'urn:oid:1.2.392.100495.20.2.61') if insurance_type.present?

            if insurance_type[:code] == '8' # 8:公費
                # IN1-3.保険会社ID(公費負担者番号)
                if in1_segment[:insurance_company_id].present?
                    coverage_class = FHIR::Coverage::Class.new
                    coverage_class.type = create_codeable_concept('1', '公費負担者番号', create_url(:code_system, 'CoverageClass'))
                    coverage_class.value = in1_segment[:insurance_company_id].first[:id_number]
                    coverage_class.name = "公費負担者番号"
                    coverage.local_class << coverage_class
                end
                # 公費受給者番号
                coverage.subscriberId = ""
            else
                # IN1-3.保険会社ID(保険者番号)
                if in1_segment[:insurance_company_id].present?
                    organization = FHIR::Organization.new
                    organization.id = SecureRandom.uuid
                    organization.identifier << create_identifier(in1_segment[:insurance_company_id].first[:id_number], 'urn:oid:1.2.392.100495.20.3.61')
                    organization.type << create_codeable_concept('pay', 'Payer', 'http://hl7.org/fhir/ValueSet/organization-type')
                    @bundle.entry.concat << create_entry(organization)
                    coverage.payor << create_reference(organization)
                end
                # IN1-10.被保険者グループ雇用者ID(記号)
                if in1_segment[:insureds_group_emp_id].present?
                    extension = FHIR::Extension.new
                    extension.url = create_url(:structure_definition, 'InsuredPersonSymbol')
                    extension.valueString = in1_segment[:insureds_group_emp_id].first[:id_number]
                    coverage.extension << extension
                end
                # IN1-11.被保険者グループ雇用者名(番号)
                if in1_segment[:insureds_group_emp_name].present?
                    extension = FHIR::Extension.new
                    extension.url = create_url(:structure_definition, 'InsuredPersonNumber')
                    extension.valueString = in1_segment[:insureds_group_emp_name].first[:organization_name]
                    coverage.extension << extension
                end
                # IN1-17.被保険者と患者の関係(本人/家族)
                if in1_segment[:insureds_relationship_to_patient].present?
                    coverage.relationship = 
                        case in1_segment[:insureds_relationship_to_patient].first[:identifier]
                        when 'SEL', 'EME'
                            create_codeable_concept('1', '被保険者', 'urn:oid:1.2.392.100495.20.2.62')
                        when 'EXF', 'SPO', 'CHD'
                            create_codeable_concept('2', '被扶養者', 'urn:oid:1.2.392.100495.20.2.62')
                        end
                end
                # 患者負担率
                cost = FHIR::Coverage::CostToBeneficiary.new
                cost.type = create_codeable_concept('copaypct', 'Copay Percentage', 'http://hl7.org/fhir/ValueSet/coverage-copay-type')
                cost.valueQuantity = create_quantity(30, '%', 'http://unitsofmeasure.org') # MEMO:とりあえず仮設定で30%
                coverage.costToBeneficiary << cost

                period = FHIR::Period.new
                # IN1-12.プラン有効日付(有効開始日)                
                period.start = Date.parse(in1_segment[:plan_effective_date]) if in1_segment[:plan_effective_date].present?
                # IN1-13.プラン失効日付(有効終了日)
                period.end = Date.parse(in1_segment[:plan_expiration_date]) if in1_segment[:plan_expiration_date].present?
                coverage.period = period
            end

            # Patientリソースの参照
            coverage.beneficiary = create_reference(get_resources_from_type('Patient').first)

            results << create_entry(coverage)
        end

        # Section
        get_composition.section.first.entry.concat results.map{|entry|create_reference(entry.resource)}
        
        results
    end

    private
    # JHSD表:0001(保険種別) -> 電子処方箋CDA:1.2.392.100495.20.2.61(保険種別コード) 変換
    def get_insurance_type(value)
        @jahis_tables ||= File.open(Pathname.new(File.dirname(File.expand_path(__FILE__))).join('json').join('JAHIS_TABLES.json')) do |io|
            JSON.load(io)
        end
        jhsd = @jahis_tables['JHSD0001'].find{|c|c['value'] == value}
        return unless jhsd.present?

        case jhsd['type']
        when 'MI' # 医保
            case jhsd['value']
            when 'C0' then {code:'2', name:'国保'} # 国保
            when '39' then {code:'7', name:'後期高齢'} # 後期高齢
            else {code:'1', name:'社保'} # 社保
            end
        when 'LI' then {code:'3', name:'労災'} # 労災
        when 'TI' then {code:'4', name:'自賠'} # 自賠
        when 'PS' then {code:'5', name:'公害'} # 公害
        when 'OE' then {code:'6', name:'自費'} # 自費
        when 'PE' then {code:'8', name:'公費'} # 公費
        end
    end
end