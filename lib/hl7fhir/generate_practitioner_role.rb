require_relative 'generate_abstract'

class GeneratePractitionerRole < GenerateAbstract
    def perform()
        practitioner_role = FHIR::PractitionerRole.new
        practitioner_role.id = SecureRandom.uuid

        practitioner_role.code << create_codeable_concept('doctor','Doctor','http://terminology.hl7.org/CodeSystem/practitioner-role')
        practitioner_role.practitioner = create_reference(get_resources_from_type('Practitioner').first.resource)
        practitioner_role.organization = create_reference(get_resources_from_type('Organization').first.resource)
        practitioner_role.specialty

        code = get_clinical_document.xpath('author/assignedAuthor/representedOrganization/asOrganizationPartOf/code')
        practitioner_role.specialty << generate_codeable_concept(code)

        composition = get_composition.resource
        composition.author << create_reference(practitioner_role)

        entry = FHIR::Bundle::Entry.new
        entry.resource = practitioner_role
        [entry]
    end
end