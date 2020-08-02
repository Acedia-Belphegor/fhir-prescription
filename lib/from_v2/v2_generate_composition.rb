require_relative 'v2_generate_abstract'

class V2GenerateComposition < V2GenerateAbstract
    def perform()
        composition = FHIR::Composition.new
        composition.id = SecureRandom.uuid

        msh_segment = get_segments('MSH')&.first
        return unless msh_segment.present?

        composition.status = :preliminary
        composition.type = create_codeable_concept('01', '処方箋', 'urn:oid:1.2.392.100495.20.2.11')
        composition.date = DateTime.parse(msh_segment[:datetime_of_message].first[:time])
        composition.title = '処方箋'
        composition.confidentiality = 'N'

        entry = FHIR::Bundle::Entry.new
        entry.resource = composition
        [entry]
    end
end