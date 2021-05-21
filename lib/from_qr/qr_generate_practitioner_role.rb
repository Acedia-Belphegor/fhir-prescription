require_relative 'qr_generate_abstract'

class QrGeneratePractitionerRole < QrGenerateAbstract
  def perform()
    practitioner_role = FHIR::PractitionerRole.new
    practitioner_role.id = SecureRandom.uuid

    practitioner_role.code << build_codeable_concept('doctor','Doctor','http://terminology.hl7.org/CodeSystem/practitioner-role') # 医師
    practitioner_role.practitioner = build_reference(get_resources_from_type('Practitioner').first)
    practitioner_role.organization = build_reference(get_resources_from_type('Organization').first)

    composition = get_composition
    composition.author << build_reference(practitioner_role)

    [build_entry(practitioner_role)]
  end
end