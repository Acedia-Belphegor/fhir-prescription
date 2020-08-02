require_relative 'generate_abstract'

class GenerateOrganization < GenerateAbstract
    def perform()
        organization = FHIR::Organization.new
        organization.id = SecureRandom.uuid

        represented_rganization = get_clinical_document.xpath('author/assignedAuthor/representedOrganization')
        return unless represented_rganization.present?

        organization.identifier = represented_rganization.xpath('id').map{ |id| generate_identifier(id) }
        organization.name = represented_rganization.xpath('name').text
        organization.address = represented_rganization.xpath('addr').map{ |addr| generate_address(addr) }
        organization.telecom = represented_rganization.xpath('telecom').map{ |telecom| generate_contact_point(telecom) }

        entry = FHIR::Bundle::Entry.new
        entry.resource = organization
        [entry]
    end
end