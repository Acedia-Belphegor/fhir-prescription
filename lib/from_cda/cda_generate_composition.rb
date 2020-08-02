require_relative 'cda_generate_abstract'

class CdaGenerateComposition < CdaGenerateAbstract
    def perform()
        composition = FHIR::Composition.new
        composition.id = SecureRandom.uuid

        clinical_document = get_clinical_document
        return unless clinical_document.present?

        composition.status = :preliminary
        composition.type = create_codeable_concept(
            clinical_document.xpath('code/@code').text,
            clinical_document.xpath('effectiveTime/title').text,
            clinical_document.xpath('code/@codeSystem').text
        )
        composition.date = DateTime.parse(clinical_document.xpath('effectiveTime/@value').text)
        composition.title = clinical_document.xpath('effectiveTime/title').text
        composition.confidentiality = clinical_document.xpath('confidentialityCode/@code').text

        entry = FHIR::Bundle::Entry.new
        entry.resource = composition
        [entry]
    end
end