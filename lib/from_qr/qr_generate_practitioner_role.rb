require_relative 'qr_generate_abstract'

class QrGeneratePractitionerRole < QrGenerateAbstract
    def perform()
        practitioner_role = FHIR::PractitionerRole.new
        practitioner_role.id = SecureRandom.uuid

        practitioner_role.code << create_codeable_concept('doctor','Doctor','http://terminology.hl7.org/CodeSystem/practitioner-role') # 医師
        practitioner_role.practitioner = create_reference(get_resources_from_type('Practitioner').first.resource)
        practitioner_role.organization = create_reference(get_resources_from_type('Organization').first.resource)

        # 診療科レコード
        department_record = get_records(4)&.first
        if department_record.present?
            practitioner_role.specialty << create_codeable_concept(department_record[:department_code], department_record[:department_name])
        end

        composition = get_composition.resource
        composition.author << create_reference(practitioner_role)

        entry = FHIR::Bundle::Entry.new
        entry.resource = practitioner_role
        [entry]
    end
end