require_relative 'cda_generate_abstract'

class CdaGeneratePractitionerRole < CdaGenerateAbstract
  def perform()
    practitioner_role = FHIR::PractitionerRole.new
    practitioner_role.id = SecureRandom.uuid

    practitioner_role.code << case get_clinical_document.xpath('code/@code').text
                              when '01' # 処方箋
                                build_codeable_concept('doctor','Doctor','http://terminology.hl7.org/CodeSystem/practitioner-role') # 医師
                              when '02' # 調剤結果
                                build_codeable_concept('pharmacist','Pharmacist','http://terminology.hl7.org/CodeSystem/practitioner-role') # 薬剤師
                              end
    practitioner_role.practitioner = build_reference(get_resources_from_type('Practitioner').first)
    practitioner_role.organization = build_reference(get_resources_from_type('Organization').first)

    get_composition.author << build_reference(practitioner_role)

    [build_entry(practitioner_role)]
  end
end