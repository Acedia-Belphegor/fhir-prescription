require_relative 'generate_abstract'

class GenerateOrganization < GenerateAbstract
    def perform()
        organization = FHIR::Organization.new
        organization.id = SecureRandom.uuid

        orc_segment = get_segments('ORC')&.first
        return unless orc_segment.present?

        # organization.identifier = orc_segment[:patient_identifier_list].map{|element|
        #     identifier = FHIR::Identifier.new
        #     identifier.system = "urn:oid:1.2.392.100495.20.3.51.1"
        #     identifier.value = element[:id_number]
        #     identifier
        # }
        organization.name = orc_segment[:ordering_facility_name].first[:organization_name]
        organization.address = orc_segment[:ordering_facility_address].map{|addr|generate_address(addr)} if orc_segment[:ordering_facility_address].present?
        organization.telecom = orc_segment[:ordering_facility_phone_number].map{|telecom|generate_contact_point(telecom)} if orc_segment[:ordering_facility_phone_number].present?

        entry = FHIR::Bundle::Entry.new
        entry.resource = organization
        [entry]
    end
end