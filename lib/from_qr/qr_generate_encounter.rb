require_relative 'qr_generate_abstract'

class QrGenerateEncounter < QrGenerateAbstract
    def perform()
        encounter = FHIR::Encounter.new
        encounter.id = SecureRandom.uuid
        encounter.status = :finished
        encounter.local_class = create_coding('AMB', '外来', 'http://terminology.hl7.org/CodeSystem/v3-ActCode')

        composition = get_composition
        composition.encounter = create_reference(encounter)

        [create_entry(encounter)]
    end
end