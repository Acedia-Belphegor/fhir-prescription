require_relative 'orca_generate_abstract'

class OrcaGenerateOrganization < OrcaGenerateAbstract
    def perform()
        # 医療機関情報
        orca_hospital = get_orcadata["Hospital"]
        return unless orca_hospital.present?

        organization = FHIR::Organization.new
        organization.id = SecureRandom.uuid
        results = []

        organization.identifier << create_identifier(orca_hospital["Prefectures_Number"], 'urn:oid:1.2.392.100495.20.3.21') # 都道府県番号
        organization.identifier << create_identifier('1', 'urn:oid:1.2.392.100495.20.3.22')
        organization.identifier << create_identifier(orca_hospital["Code"], 'urn:oid:1.2.392.100495.20.3.23') # 医療機関コード
        organization.name = orca_hospital["Name"].join # 医療機関名称(*3)
        organization.type << create_codeable_concept('prov', 'Healthcare Provider', 'http://hl7.org/fhir/ValueSet/organization-type')

        address = FHIR::Address.new
        address.line << orca_hospital["Address"].join # 住所(*3)
        address.postalCode = orca_hospital["ZipCode"] # 郵便番号
        organization.address << address

        # tel
        if orca_hospital["PhoneNumber"].present?
            contact_point = FHIR::ContactPoint.new
            contact_point.system = :phone
            contact_point.value = orca_hospital["PhoneNumber"] # 電話番号
            organization.telecom << contact_point
        end

        # fax
        if orca_hospital["FaxNumber"].present?
            contact_point = FHIR::ContactPoint.new
            contact_point.system = :fax
            contact_point.value = orca_hospital["FaxNumber"] # FAX番号
            organization.telecom << contact_point
        end

        entry = FHIR::Bundle::Entry.new
        entry.resource = organization
        results << entry

        # 診療科
        if get_orcadata["Department_Code"].present?
            organization = FHIR::Organization.new
            organization.id = SecureRandom.uuid
    
            organization.identifier << create_identifier(get_orcadata["Department_Code"], "LC") # 診療科コード
            organization.name = get_orcadata["Department_Name"] # 診療科名
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