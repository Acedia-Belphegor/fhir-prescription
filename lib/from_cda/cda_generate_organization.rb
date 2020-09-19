require_relative 'cda_generate_abstract'

class CdaGenerateOrganization < CdaGenerateAbstract
    def perform()
        results = []

        # 医療機関情報
        represented_rganization = get_clinical_document.xpath('author/assignedAuthor/representedOrganization')
        if represented_rganization.present?
            organization = FHIR::Organization.new
            organization.id = SecureRandom.uuid

            organization.identifier = represented_rganization.xpath('id').map{ |id| generate_identifier(id) }
            organization.name = represented_rganization.xpath('name').text
            organization.address = represented_rganization.xpath('addr').map{ |addr| generate_address(addr) }
            organization.telecom = represented_rganization.xpath('telecom').map{ |telecom| generate_contact_point(telecom) }
            organization.type << create_codeable_concept('prov', 'Healthcare Provider', 'http://hl7.org/fhir/ValueSet/organization-type')

            entry = FHIR::Bundle::Entry.new
            entry.resource = organization
            results << entry
        end

        # 診療科情報
        code = get_clinical_document.xpath('author/assignedAuthor/representedOrganization/asOrganizationPartOf/code')
        if code.present?
            organization = FHIR::Organization.new
            organization.id = SecureRandom.uuid

            organization.identifier = create_identifier(code.xpath('@code').text, "urn:oid:#{code.xpath('@codeSystem').text}")
            organization.name = code.xpath('@displayName').text
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