require_relative 'cda_generate_abstract'

class CdaGenerateComposition < CdaGenerateAbstract
    def perform()
        composition = FHIR::Composition.new
        composition.id = SecureRandom.uuid

        clinical_document = get_clinical_document
        return unless clinical_document.present?

        composition.identifier = clinical_document.xpath('id').map{|id|generate_identifier(id)}&.first
        composition.status = :final
        composition.type = create_codeable_concept(
            clinical_document.xpath('code/@code').text,
            clinical_document.xpath('title').text,
            clinical_document.xpath('code/@codeSystem').text
        )
        composition.category << create_codeable_concept('01', '一般処方箋', create_url(:code_system, 'PrescriptionCategory'))
        composition.date = DateTime.parse(clinical_document.xpath('effectiveTime/@value').text)
        composition.title = clinical_document.xpath('title').text
        composition.confidentiality = clinical_document.xpath('confidentialityCode/@code').text

        # 処方箋発行者情報
        author = get_clinical_document.xpath('author')
        if author.present?
            period = FHIR::Period.new
            # 処方箋交付年月日
            period.start = author.xpath('time/low/@value').text
            # 処方箋有効期限
            period.end = author.xpath('time/high/@value').text
            event = FHIR::Composition::Event.new
            event.period = period
            composition.event = event
        end

        section = FHIR::Composition::Section.new
        section.title = '処方情報'
        section.code = create_codeable_concept('01', '処方情報', 'urn:oid:1.2.392.100495.20.2.12')
        composition.section << section

        # 文書のバージョン
        extension = FHIR::Extension.new
        extension.url = create_url(:structure_definition, 'composition-clinicaldocument-versionNumber')
        extension.valueString = "1.0"
        composition.extension << extension

        [create_entry(composition)]
    end
end