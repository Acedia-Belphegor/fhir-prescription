require_relative 'cda_generate_abstract'

class CdaGenerateCoverage < CdaGenerateAbstract
    def perform()
        component = get_clinical_document.xpath('component/structuredBody/component').find{ |c| 
            c.xpath("section/code/@code").text == '11' && 
            c.xpath("section/code/@codeSystem").text == '1.2.392.100495.20.2.12' 
        }
        return unless component.present?
        results = []

        # section = FHIR::Composition::Section.new
        # section.title = component.xpath('section/title').text
        # section.code = generate_codeable_concept(component.xpath('section/code'))
        # section.text = component.xpath('section/text/list/item').map{ |item| item.text }.join('\n')

        component.xpath('section/entry/act/entryRelationship').each do |entry_relationship|
            coverage = FHIR::Coverage.new
            coverage.id = SecureRandom.uuid
            coverage.status = :draft

            act = entry_relationship.xpath('act')

            # 保険種別
            coverage.type = generate_codeable_concept(act.xpath('code'))

            # if act.xpath('code/@code').text == '8'
            #     # 公費負担者番号
            #     id = act.xpath('performer/assignedEntity/id').find{ |id| id.xpath('@root').text == '1.2.392.100495.20.3.71' }
            #     if id.present?
            #         coverage.identifier << generate_identifier(id)
            #     end
            #     # 公費受給者番号
            #     id = act.xpath('participant/participantRole/id').find{ |id| id.xpath('@root').text == '1.2.392.100495.20.3.72' }
            #     if id.present?
            #         coverage.identifier << generate_identifier(id)
            #     end
            # else
            #     # 保険者番号
            #     id = act.xpath('performer/assignedEntity/id').find{ |id| id.xpath('@root').text == '1.2.392.100495.20.3.61' }
            #     if id.present?
            #         coverage.identifier << generate_identifier(id)
            #     end
            #     # 被保険者証記号/番号
            #     coverage.identifier = act.xpath('participant/participantRole/id').select{ |id| id.xpath('@root').text.in? ['1.2.392.100495.20.3.62','1.2.392.100495.20.3.63'] }.map{ |id| generate_identifier(id) }
            #     # 患者区分
            #     coverage.relationship = generate_codeable_concept(act.xpath('participant/participantRole/code'))

            #     cost = FHIR::Coverage::CostToBeneficiary.new
            #     cost.type = create_codeable_concept('copaypct', 'Copay Percentage', 'http://hl7.org/fhir/ValueSet/coverage-copay-type')
            #     cost.valueQuantity = create_quantity(30, '%') # MEMO:とりあえず仮設定で30%

            #     # 患者一部負担区分
            #     if act.xpath("entryRelationship").present?
            #         exception = FHIR::Coverage::CostToBeneficiary::Exception.new
            #         exception.type = generate_codeable_concept(act.xpath('entryRelationship/observation/code'))
            #         cost.exception << exception
            #     end
            #     coverage.costToBeneficiary << cost
            # end

            if act.xpath('code/@code').text == '8'
                # 公費負担者番号
                id = act.xpath('performer/assignedEntity/id').find{ |id| id.xpath('@root').text == '1.2.392.100495.20.3.71' }
                if id.present?
                    extension = FHIR::Extension.new
                    extension.url = "http://hl7fhir.jp/fhir/StructureDefinition/Extension-JPCore-xxx"
                    extension.valueString = id.xpath('@extension').text
                    coverage.extension << extension
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
                    organization.type << create_codeable_concept('pay', 'Payer', 'http://hl7.org/fhir/ValueSet/organization-type')
                    entry = FHIR::Bundle::Entry.new
                    entry.resource = organization
                    @bundle.entry.concat << entry
                    coverage.payor << create_reference(organization)
                end

                # 被保険者証記号/番号
                coverage.subscriberId = act.xpath('participant/participantRole/id').select{ |id| id.xpath('@root').text.in? ['1.2.392.100495.20.3.62','1.2.392.100495.20.3.63'] }.map{ |id| id.xpath('@extension').text }.join(" ")
                # 枝番
                coverage.dependent = ""
                # 患者区分
                coverage.relationship = generate_codeable_concept(act.xpath('participant/participantRole/code'))

                cost = FHIR::Coverage::CostToBeneficiary.new
                cost.type = create_codeable_concept('copaypct', 'Copay Percentage', 'http://hl7.org/fhir/ValueSet/coverage-copay-type')
                cost.valueQuantity = create_quantity(30, '%') # MEMO:とりあえず仮設定で30%

                # 患者一部負担区分
                if act.xpath("entryRelationship").present?
                    exception = FHIR::Coverage::CostToBeneficiary::Exception.new
                    exception.type = generate_codeable_concept(act.xpath('entryRelationship/observation/code'))
                    cost.exception << exception
                end
                coverage.costToBeneficiary << cost
            end

            entry = FHIR::Bundle::Entry.new
            entry.resource = coverage
            results << entry
        end

        get_composition.resource.section.first.entry.concat results.map{|entry|create_reference(entry.resource)}
        results
    end
end