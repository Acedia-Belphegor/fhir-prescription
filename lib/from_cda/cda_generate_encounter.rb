require_relative 'cda_generate_abstract'

class CdaGenerateEncounter < CdaGenerateAbstract
  def perform()
    encounter = FHIR::Encounter.new
    encounter.id = SecureRandom.uuid
    encounter.status = :finished
    encounter.local_class = build_coding('AMB', '外来', 'http://terminology.hl7.org/CodeSystem/v3-ActCode')

    composition = get_composition
    composition.encounter = build_reference(encounter)

    [build_entry(encounter)]
  end
end