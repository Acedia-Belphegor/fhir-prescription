require_relative 'qr_generate_abstract'

class QrGenerateEncounter < QrGenerateAbstract
    def perform()
        encounter = FHIR::Encounter.new
        encounter.id = SecureRandom.uuid
        encounter.status = :finished
        encounter.local_class = create_coding('AMB', '外来', 'http://terminology.hl7.org/CodeSystem/v3-ActCode')

        composition = get_composition.resource
        composition.encounter = create_reference(encounter)

        entry = FHIR::Bundle::Entry.new
        entry.resource = encounter
        [entry]
    end
end