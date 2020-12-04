require_relative 'v2_generate_abstract'

class V2GenerateEncounter < V2GenerateAbstract
    def perform()
        orc_segment = get_segments('ORC')&.first
        return [] unless orc_segment.present?

        encounter = FHIR::Encounter.new
        encounter.id = SecureRandom.uuid
        encounter.status = :finished
        if orc_segment[:order_type].present?
            encounter.local_class = case orc_segment[:order_type].first[:identifier]
                when 'O' then create_coding('AMB', '外来', 'http://terminology.hl7.org/CodeSystem/v3-ActCode')
                when 'I' then create_coding('IMB', '入院', 'http://terminology.hl7.org/CodeSystem/v3-ActCode')
                end
        end
        composition = get_composition.resource
        composition.encounter = create_reference(encounter)

        entry = FHIR::Bundle::Entry.new
        entry.resource = encounter
        [entry]
    end
end