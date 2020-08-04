require_relative 'qr_generate_abstract'

class QrGenerateComposition < QrGenerateAbstract
    def perform()
        composition = FHIR::Composition.new
        composition.id = SecureRandom.uuid
        composition.status = :preliminary
        composition.type = create_codeable_concept('01', '処方箋', 'urn:oid:1.2.392.100495.20.2.11')
        composition.date = DateTime.now
        composition.title = '処方箋'
        composition.confidentiality = 'N'

        entry = FHIR::Bundle::Entry.new
        entry.resource = composition
        [entry]
    end
end