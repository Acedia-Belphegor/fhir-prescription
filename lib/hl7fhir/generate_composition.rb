require_relative 'generate_abstract'

class GenerateComposition < GenerateAbstract
    def perform()
        composition = FHIR::Composition.new
        composition.id = SecureRandom.uuid

        clinical_document = get_clinical_document
        return unless clinical_document.present?

        composition.status = :preliminary
        composition.type = create_codeable_concept('01','処方箋','urn:oid:1.2.392.100495.20.2.11')
        composition.date = DateTime.parse(clinical_document.xpath('effectiveTime/@value').text)
        composition.title = clinical_document.xpath('effectiveTime/title').text
        composition.confidentiality = clinical_document.xpath('confidentialityCode/@code').text

        entry = FHIR::Bundle::Entry.new
        entry.resource = composition
        [entry]
    end
end