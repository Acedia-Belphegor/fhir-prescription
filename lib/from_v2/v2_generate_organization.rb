require_relative 'v2_generate_abstract'

class V2GenerateOrganization < V2GenerateAbstract
    def perform()
        orc_segment = get_segments('ORC')&.first
        return [] unless orc_segment.present?

        results = []
        organization = FHIR::Organization.new
        organization.id = SecureRandom.uuid

        organization.identifier << create_identifier(
            "#{get_params[:prefecture_code]}#{get_params[:medical_fee_point_code]}#{get_params[:medical_institution_code]}", 
            create_url(:name_space, 'InsuranceMedicalInstitutionNo')
        )
        # 都道府県番号
        extension = FHIR::Extension.new
        extension.valueIdentifier = create_identifier(get_params[:prefecture_code], '1.2.392.100495.20.3.21')
        extension.url = create_url(:structure_definition, 'PrefectureNo')
        organization.extension << extension

        # 点数表コード
        extension = FHIR::Extension.new
        extension.valueIdentifier = create_identifier(get_params[:medical_fee_point_code], '1.2.392.100495.20.3.22')
        extension.url = create_url(:structure_definition, 'OrganizationCategory')
        organization.extension << extension

        # 保険医療機関番号
        extension = FHIR::Extension.new
        extension.valueIdentifier = create_identifier(get_params[:medical_institution_code], '1.2.392.100495.20.3.23')
        extension.url = create_url(:structure_definition, 'OrganizationNo')
        organization.extension << extension

        organization.name = orc_segment[:ordering_facility_name].first[:organization_name] if orc_segment[:ordering_facility_name].present?
        organization.address = orc_segment[:ordering_facility_address].map{|addr|generate_address(addr)} if orc_segment[:ordering_facility_address].present?
        organization.telecom = orc_segment[:ordering_facility_phone_number].map{|telecom|generate_contact_point(telecom)} if orc_segment[:ordering_facility_phone_number].present?
        organization.type << create_codeable_concept('prov', 'Healthcare Provider', 'http://hl7.org/fhir/ValueSet/organization-type')

        entry = FHIR::Bundle::Entry.new
        entry.resource = organization
        results << entry

        # 診療科
        if orc_segment[:entering_organization].present?
            organization = FHIR::Organization.new
            organization.id = SecureRandom.uuid
    
            dept = orc_segment[:entering_organization].first
            organization.identifier << create_identifier(dept[:identifier], create_url(:name_space, 'DepartmentCode'))
            organization.name = dept[:text]
            organization.type << create_codeable_concept('dept', 'Hospital Department', 'http://hl7.org/fhir/ValueSet/organization-type')

            if results.present?
                results.first.resource.partOf = create_reference(organization)
            end

            entry = FHIR::Bundle::Entry.new
            entry.resource = organization
            results << entry
        end

        results
    end
end