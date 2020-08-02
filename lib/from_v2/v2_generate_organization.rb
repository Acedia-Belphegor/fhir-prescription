require_relative 'v2_generate_abstract'

class V2GenerateOrganization < V2GenerateAbstract
    def perform()
        organization = FHIR::Organization.new
        organization.id = SecureRandom.uuid

        orc_segment = get_segments('ORC')&.first
        return unless orc_segment.present?

        organization.identifier << generate_identifier(get_params[:prefecture_code], '1.2.392.100495.20.3.21')
        organization.identifier << generate_identifier(get_params[:medical_fee_point_code], '1.2.392.100495.20.3.22')
        organization.identifier << generate_identifier(get_params[:medical_institution_code], '1.2.392.100495.20.3.23')
        organization.name = orc_segment[:ordering_facility_name].first[:organization_name]
        organization.address = orc_segment[:ordering_facility_address].map{|addr|generate_address(addr)} if orc_segment[:ordering_facility_address].present?
        organization.telecom = orc_segment[:ordering_facility_phone_number].map{|telecom|generate_contact_point(telecom)} if orc_segment[:ordering_facility_phone_number].present?

        entry = FHIR::Bundle::Entry.new
        entry.resource = organization
        [entry]
    end
end