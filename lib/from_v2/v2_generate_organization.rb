require_relative 'v2_generate_abstract'

class V2GenerateOrganization < V2GenerateAbstract
  def perform()
    orc_segment = get_segments('ORC')&.first
    return [] unless orc_segment.present?

    results = []
    organization = FHIR::Organization.new
    organization.id = SecureRandom.uuid

    organization.identifier << build_identifier(
      "#{get_params[:prefecture_code]}#{get_params[:medical_fee_point_code]}#{get_params[:medical_institution_code]}", 
      build_url(:name_space, 'InsuranceMedicalInstitutionNo')
    )
    # 都道府県番号
    extension = FHIR::Extension.new
    extension.valueIdentifier = build_identifier(get_params[:prefecture_code], '1.2.392.100495.20.3.21')
    extension.url = build_url(:structure_definition, 'PrefectureNo')
    organization.extension << extension

    # 点数表コード
    extension = FHIR::Extension.new
    extension.valueIdentifier = build_identifier(get_params[:medical_fee_point_code], '1.2.392.100495.20.3.22')
    extension.url = build_url(:structure_definition, 'OrganizationCategory')
    organization.extension << extension

    # 保険医療機関番号
    extension = FHIR::Extension.new
    extension.valueIdentifier = build_identifier(get_params[:medical_institution_code], '1.2.392.100495.20.3.23')
    extension.url = build_url(:structure_definition, 'OrganizationNo')
    organization.extension << extension

    organization.name = orc_segment[:ordering_facility_name].first[:organization_name] if orc_segment[:ordering_facility_name].present?
    organization.address = orc_segment[:ordering_facility_address].map{|addr|generate_address(addr)} if orc_segment[:ordering_facility_address].present?
    organization.telecom = orc_segment[:ordering_facility_phone_number].map{|telecom|generate_contact_point(telecom)} if orc_segment[:ordering_facility_phone_number].present?
    organization.type << build_codeable_concept('prov', 'Healthcare Provider', 'http://terminology.hl7.org/CodeSystem/organization-type')

    results << build_entry(organization)

    # 診療科
    if orc_segment[:entering_organization].present?
      organization = FHIR::Organization.new
      organization.id = SecureRandom.uuid

      dept = orc_segment[:entering_organization].first
      organization.name = dept[:text]
      organization.type << build_codeable_concept('dept', 'Hospital Department', 'http://terminology.hl7.org/CodeSystem/organization-type')
      organization.type << generate_codeable_concept(dept)

      # 医療機関
      organization.partOf = build_reference(results.first.resource)

      results << build_entry(organization)
    end

    results
   end
end