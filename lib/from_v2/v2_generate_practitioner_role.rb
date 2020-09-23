require_relative 'v2_generate_abstract'

class V2GeneratePractitionerRole < V2GenerateAbstract
    def perform()
        practitioner_role = FHIR::PractitionerRole.new
        practitioner_role.id = SecureRandom.uuid

        orc_segment = get_segments('ORC')&.first
        return [] unless orc_segment.present?

        practitioner_role.code << create_codeable_concept('doctor','Doctor','http://terminology.hl7.org/CodeSystem/practitioner-role') # 医師
        practitioner_role.practitioner = create_reference(get_resources_from_type('Practitioner').first.resource)
        practitioner_role.organization = create_reference(get_resources_from_type('Organization').first.resource)
        # practitioner_role.specialty.concat orc_segment[:entering_organization].map{|element|generate_codeable_concept(element)} if orc_segment[:entering_organization].present?

        composition = get_composition.resource
        composition.author << create_reference(practitioner_role)

        entry = FHIR::Bundle::Entry.new
        entry.resource = practitioner_role
        [entry]
    end
end