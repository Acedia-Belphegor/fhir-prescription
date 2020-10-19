require_relative 'sips_generate_abstract'

class SipsGenerateOrganization < SipsGenerateAbstract
    def perform()
        [generate_medical_institution_resource, generate_pharmacy_resource].flatten
    end

    # 医療機関リソース生成
    def generate_medical_institution_resource()
        prescription_record = get_records(PRESCRIPTION)&.first
        return unless prescription_record.present?

        results = []
        organization = FHIR::Organization.new
        organization.id = SecureRandom.uuid

        # 点数表
        tensuhyo = case prescription_record[:medical_institution_code_kind]
                   when '0' then '1' # 医科
                   when '3' then '2' # 歯科
                   when '6' then '6' # 訪問看護
                   end

        organization.identifier << create_identifier(prescription_record[:medical_institution_prefecture_code], 'urn:oid:1.2.392.100495.20.3.21')
        organization.identifier << create_identifier(tensuhyo, 'urn:oid:1.2.392.100495.20.3.22')
        organization.identifier << create_identifier(prescription_record[:medical_institution_receipt_code], 'urn:oid:1.2.392.100495.20.3.23')
        organization.name = prescription_record[:medical_institution_name]
        organization.type << create_codeable_concept('prov', 'Healthcare Provider', 'http://hl7.org/fhir/ValueSet/organization-type')

        address = FHIR::Address.new
        address.line << prescription_record[:medical_institution_address]
        address.postalCode = prescription_record[:medical_institution_postalcode]
        organization.address << address

        if prescription_record[:medical_institution_tel].present?
            contact_point = FHIR::ContactPoint.new
            contact_point.system = :phone
            contact_point.value = prescription_record[:medical_institution_tel]
            organization.telecom << contact_point
        end

        entry = FHIR::Bundle::Entry.new
        entry.resource = organization
        results << entry

        # 診療科
        if prescription_record[:department_code].present?
            organization = FHIR::Organization.new
            organization.id = SecureRandom.uuid
    
            organization.identifier << create_identifier(prescription_record[:department_code], 'LC')
            organization.name = prescription_record[:department_name]
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

    # 薬局リソース生成
    def generate_pharmacy_resource()
        header_record = get_all_records.first
        return unless header_record.present?

        organization = FHIR::Organization.new
        organization.id = SecureRandom.uuid

        organization.identifier << create_identifier(header_record[:prefecture_code], 'urn:oid:1.2.392.100495.20.3.21')
        organization.identifier << create_identifier(header_record[:tensuhyo], 'urn:oid:1.2.392.100495.20.3.22')
        organization.identifier << create_identifier(header_record[:pharmacy_code], 'urn:oid:1.2.392.100495.20.3.23')
        organization.name = header_record[:pharmacy_name]
        organization.type << create_codeable_concept('prov', 'Healthcare Provider', 'http://hl7.org/fhir/ValueSet/organization-type')

        address = FHIR::Address.new
        address.line << header_record[:pharmacy_address]
        address.postalCode = header_record[:pharmacy_postal_code]
        organization.address << address

        if header_record[:pharmacy_phone].present?
            contact_point = FHIR::ContactPoint.new
            contact_point.system = :phone
            contact_point.value = header_record[:pharmacy_phone]
            organization.telecom << contact_point
        end

        entry = FHIR::Bundle::Entry.new
        entry.resource = organization
        entry
    end
end