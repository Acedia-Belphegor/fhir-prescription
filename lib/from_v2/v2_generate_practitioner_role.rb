require_relative 'v2_generate_abstract'

class V2GeneratePractitionerRole < V2GenerateAbstract
  def perform()
    practitioner_role = FHIR::PractitionerRole.new
    practitioner_role.id = SecureRandom.uuid

    orc_segment = get_segments('ORC')&.first
    return [] unless orc_segment.present?

    practitioner_role.code << build_codeable_concept('doctor','Doctor','http://terminology.hl7.org/CodeSystem/practitioner-role') # 医師
    practitioner_role.practitioner = build_reference(get_resources_from_type('Practitioner').first)
    practitioner_role.organization = build_reference(get_resources_from_type('Organization').first)

    [build_entry(practitioner_role)]
  end
end