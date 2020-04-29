require_relative 'generate_abstract'

class GenerateOrganization < GenerateAbstract
    def perform()
        organization = FHIR::Organization.new
        organization.id = SecureRandom.uuid

        represented_rganization = get_clinical_document.xpath('author/assignedAuthor/representedOrganization')
        return unless represented_rganization.present?

        represented_rganization.xpath('id').each{ |id| organization.identifier << generate_identifier(id) }
        organization.name = represented_rganization.xpath('name').text
        represented_rganization.xpath('addr').each{ |addr| organization.address << generate_address(addr) }
        represented_rganization.xpath('telecom').each{ |telecom| organization.telecom << generate_contact_point(telecom) }

        entry = FHIR::Bundle::Entry.new
        entry.resource = organization
        [entry]
    end
end