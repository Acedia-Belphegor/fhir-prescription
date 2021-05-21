require_relative 'cda_generate_abstract'

class CdaGenerateOrganization < CdaGenerateAbstract
  def perform()
    results = []

    # 医療機関情報
    represented_rganization = get_clinical_document.xpath('author/assignedAuthor/representedOrganization')
    if represented_rganization.present?
      organization = FHIR::Organization.new
      organization.id = SecureRandom.uuid

      organization.identifier = build_identifier(
        represented_rganization.xpath('id').map{ |id| id.xpath('@extension').text }.join, 
        build_url(:name_space, 'InsuranceMedicalInstitutionNo')
      )
      organization.extension = represented_rganization.xpath('id').map{|id| 
        extension = FHIR::Extension.new
        extension.valueIdentifier = generate_identifier(id)
        extension.url = convert_oid_to_url(extension.valueIdentifier.system)
        extension
      }
      organization.name = represented_rganization.xpath('name').text
      organization.address = represented_rganization.xpath('addr').map{ |addr| generate_address(addr) }
      organization.telecom = represented_rganization.xpath('telecom').map{ |telecom| generate_contact_point(telecom) }
      organization.type << build_codeable_concept('prov', 'Healthcare Provider', 'http://terminology.hl7.org/CodeSystem/organization-type')

      results << build_entry(organization)
    end

    # 診療科情報
    code = get_clinical_document.xpath('author/assignedAuthor/representedOrganization/asOrganizationPartOf/code')
    if code.present?
      organization = FHIR::Organization.new
      organization.id = SecureRandom.uuid

      organization.identifier = build_identifier(code.xpath('@code').text, build_url(:name_space, 'DepartmentCode'))
      organization.name = code.xpath('@displayName').text
      organization.type << build_codeable_concept('dept', 'Hospital Department', 'http://terminology.hl7.org/CodeSystem/organization-type')

      if results.present?
        results.first.resource.partOf = build_reference(organization)
      end

      results << build_entry(organization)
    end

    results
  end
end