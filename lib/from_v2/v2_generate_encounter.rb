require_relative 'v2_generate_abstract'

class V2GenerateEncounter < V2GenerateAbstract
  def perform()
    orc_segment = get_segments('ORC')&.first
    return [] unless orc_segment.present?

    encounter = FHIR::Encounter.new
    encounter.id = SecureRandom.uuid
    encounter.status = :finished
    if orc_segment[:order_type].present?
      system = 'http://terminology.hl7.org/CodeSystem/v3-ActCode'.freeze
      encounter.local_class = case orc_segment[:order_type].first[:identifier]
        when 'O' then build_coding('AMB', '外来', system)
        when 'I' then build_coding('IMB', '入院', system)
        end
    end
    composition = get_composition
    composition.encounter = build_reference(encounter)

    [build_entry(encounter)]
  end
end