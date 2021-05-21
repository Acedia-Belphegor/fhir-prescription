require_relative 'cda_generate_abstract'

class CdaGenerateCommunication < CdaGenerateAbstract
  def perform()
    results = []

    # 処方箋備考情報セクション
    component = get_clinical_document.xpath('component/structuredBody/component').find{ |c| 
      c.xpath("section/code/@code").text == '101' && 
      c.xpath("section/code/@codeSystem").text == '1.2.392.100495.20.2.12' 
    }
    if component.present?
      communication = FHIR::Communication.new
      communication.id = SecureRandom.uuid
      communication.status = :unknown
      communication.category = build_codeable_concept('1', '処方箋備考', build_url(:code_system, 'CommunicationCategory'))

      component.xpath('section/text/list/item').each do |item|
        extension = FHIR::Extension.new
        extension.url = build_url(:structure_definition, 'CommunicationContent')
        extension.valueString = item.text
        communication.extension << extension
      end
      entry = FHIR::Bundle::Entry.new
      entry.resource = communication
      results << entry

      if component.xpath('section/entry/supply/code').present?
        communication = FHIR::Communication.new
        communication.id = SecureRandom.uuid
        communication.status = :unknown
        communication.category = build_codeable_concept('3', '残薬確認指示', build_url(:code_system, 'CommunicationCategory'))

        extension = FHIR::Extension.new
        extension.url = build_url(:structure_definition, 'CommunicationContent')
        extension.valueCodeableConcept = generate_codeable_concept(component.xpath('section/entry/supply/code'))
        communication.extension << extension
    
        results << build_entry(communication)
      end
    end

    # 処方箋補足情報
    component = @document.xpath('/ClinicalDocument/component/structuredBody/component').find{ |c| 
      c.xpath("section/code/@code").text == '201' && 
      c.xpath("section/code/@codeSystem").text == '1.2.392.100495.20.2.12' 
    }
    if component.present?
      communication = FHIR::Communication.new
      communication.id = SecureRandom.uuid
      communication.status = :unknown
      communication.category = build_codeable_concept('1', '処方箋備考', build_url(:code_system, 'CommunicationCategory'))

      component.xpath('section/text/list/item').each do |item|
        extension = FHIR::Extension.new
        extension.url = build_url(:structure_definition, 'CommunicationContent')
        extension.valueString = item.text
        communication.extension << extension
      end
        
      results << build_entry(communication)
    end

    # Section
    get_composition.section.first.entry.concat results.map{|entry|build_reference(entry.resource)}
    
    results
  end
end