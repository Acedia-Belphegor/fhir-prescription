require_relative 'cda_generate_abstract'

class CdaGeneratePractitionerRole < CdaGenerateAbstract
    def perform()
        practitioner_role = FHIR::PractitionerRole.new
        practitioner_role.id = SecureRandom.uuid

        practitioner_role.code << case get_clinical_document.xpath('code/@code').text
                                  when '01' # 処方箋
                                      create_codeable_concept('doctor','Doctor','http://terminology.hl7.org/CodeSystem/practitioner-role') # 医師
                                  when '02' # 調剤結果
                                      create_codeable_concept('pharmacist','Pharmacist','http://terminology.hl7.org/CodeSystem/practitioner-role') # 薬剤師
                                  end
        practitioner_role.practitioner = create_reference(get_resources_from_type('Practitioner').first)
        practitioner_role.organization = create_reference(get_resources_from_type('Organization').first)

        composition = get_composition
        composition.author << create_reference(practitioner_role)

        [create_entry(practitioner_role)]
    end
end