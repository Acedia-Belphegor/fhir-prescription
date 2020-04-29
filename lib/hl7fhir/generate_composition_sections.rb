require_relative 'generate_abstract'

class GenerateCompositionSections < GenerateAbstract
    def perform()
        composition = get_composition.resource

        # 備考情報セクション
        component = get_clinical_document.xpath('component/structuredBody/component').find{ |c| 
            c.xpath("section/code/@code").text == '101' && 
            c.xpath("section/code/@codeSystem").text == '1.2.392.100495.20.2.12' 
        }
        if component.present?
            section = FHIR::Composition::Section.new
            section.title = component.xpath('section/title').text
            section.code = generate_codeable_concept(component.xpath('section/code'))
            section.text = component.xpath('section/text/list/item').text
            composition.section << section
        end

        # 処方箋補足情報
        component = @document.xpath('/ClinicalDocument/component/structuredBody/component').find{ |c| 
            c.xpath("section/code/@code").text == '201' && 
            c.xpath("section/code/@codeSystem").text == '1.2.392.100495.20.2.12' 
        }
        if component.present?
            section = FHIR::Composition::Section.new
            section.title = component.xpath('section/title').text
            section.code = generate_codeable_concept(component.xpath('section/code'))
            section.text = component.xpath('section/text/list/item').text
            composition.section << section
        end
    end
end