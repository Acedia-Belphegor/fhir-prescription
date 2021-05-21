require_relative 'cda_generate_abstract'

class CdaGenerateCoverage < CdaGenerateAbstract
  def perform()
    component = get_clinical_document.xpath('component/structuredBody/component').find{ |c| 
      c.xpath("section/code/@code").text == '11' && 
      c.xpath("section/code/@codeSystem").text == '1.2.392.100495.20.2.12' 
    }
    return unless component.present?
    results = []

    component.xpath('section/entry/act/entryRelationship').each do |entry_relationship|
      coverage = FHIR::Coverage.new
      coverage.id = SecureRandom.uuid
      coverage.status = :active

      act = entry_relationship.xpath('act')

      # 保険種別
      coverage.type = generate_codeable_concept(act.xpath('code'))

      if act.xpath('code/@code').text == '8'
        # 公費負担者番号
        id = act.xpath('performer/assignedEntity/id').find{ |id| id.xpath('@root').text == '1.2.392.100495.20.3.71' }
        if id.present?
          coverage_class = FHIR::Coverage::Class.new
          coverage_class.type = build_codeable_concept('1', '公費負担者番号', build_url(:code_system, 'CoverageClass'))
          coverage_class.value = id.xpath('@extension').text
          coverage_class.name = "公費負担者番号"
          coverage.local_class << coverage_class
        end

        # 公費受給者番号
        id = act.xpath('participant/participantRole/id').find{ |id| id.xpath('@root').text == '1.2.392.100495.20.3.72' }
        if id.present?
          coverage.subscriberId = id.xpath('@extension').text
        end

        # 公費情報連番
        if entry_relationship.xpath('sequenceNumber/@value').present?
          coverage.order = entry_relationship.xpath('sequenceNumber/@value').text.to_i
        end
      else
        # 保険者番号
        id = act.xpath('performer/assignedEntity/id').find{ |id| id.xpath('@root').text == '1.2.392.100495.20.3.61' }
        if id.present?
          organization = FHIR::Organization.new
          organization.id = SecureRandom.uuid
          organization.identifier << generate_identifier(id)
          organization.type << build_codeable_concept('pay', 'Payer', 'http://terminology.hl7.org/CodeSystem/organization-type')
          entry = FHIR::Bundle::Entry.new
          entry.resource = organization
          @bundle.entry.concat << entry
          coverage.payor << build_reference(organization)
        end

        # # 被保険者証記号/番号
        # coverage.subscriberId = act.xpath('participant/participantRole/id').select{ |id| id.xpath('@root').text.in? ['1.2.392.100495.20.3.62','1.2.392.100495.20.3.63'] }.map{ |id| id.xpath('@extension').text }.join("・")
        
        # 被保険者証記号/番号
        act.xpath('participant/participantRole/id').select{ |id| id.xpath('@root').text.in? ['1.2.392.100495.20.3.62','1.2.392.100495.20.3.63'] }.each do |id|
          extension = FHIR::Extension.new
          extension.url = build_url(:structure_definition, id.xpath('@root').text == '1.2.392.100495.20.3.62' ? 'InsuredPersonSymbol' : 'InsuredPersonNumber')
          extension.valueString = id.xpath('@extension').text
          coverage.extension << extension
        end
        # 枝番
        coverage.dependent = ""
        # 患者区分
        coverage.relationship = generate_codeable_concept(act.xpath('participant/participantRole/code'))
        # 患者負担割
        cost = FHIR::Coverage::CostToBeneficiary.new
        cost.type = build_codeable_concept('copaypct', 'Copay Percentage', 'http://terminology.hl7.org/CodeSystem/coverage-copay-type')
        cost.valueQuantity = build_quantity(30, '%', 'http://unitsofmeasure.org') # MEMO:とりあえず仮設定で30%

        # 患者一部負担区分
        if act.xpath("entryRelationship").present?
          exception = FHIR::Coverage::CostToBeneficiary::Exception.new
          exception.type = generate_codeable_concept(act.xpath('entryRelationship/observation/code'))
          cost.exception << exception
        end
        coverage.costToBeneficiary << cost
      end

      # Patientリソースの参照
      coverage.beneficiary = build_reference(get_resources_from_type('Patient').first)

      results << build_entry(coverage)
    end

    # Section
    get_composition.section.first.entry.concat results.map{|entry|build_reference(entry.resource)}
    
    results
  end
end