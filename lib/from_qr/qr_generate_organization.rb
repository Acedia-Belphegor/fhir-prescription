require_relative 'qr_generate_abstract'

class QrGenerateOrganization < QrGenerateAbstract
    def perform()
        organization = FHIR::Organization.new
        organization.id = SecureRandom.uuid

        # 医療機関レコード
        institution_record = get_records(1)&.first
        return unless institution_record.present?

        organization.identifier << generate_identifier(institution_record[:medical_institution_prefecture_code], '1.2.392.100495.20.3.21')
        organization.identifier << generate_identifier(institution_record[:medical_institution_code_kind], '1.2.392.100495.20.3.22')
        organization.identifier << generate_identifier(institution_record[:medical_institution_code], '1.2.392.100495.20.3.23')
        organization.name = institution_record[:medical_institution_name]

        # 医療機関所在地レコード
        address_record = get_records(2)&.first
        if address_record.present?
            address = FHIR::Address.new
            address.line << address_record[:medical_institution_address]
            address.postalCode = address_record[:medical_institution_postalcode]
            organization.address << address
        end

        # 医療機関電話レコード
        telephone_record = get_records(3)&.first
        if telephone_record.present?
            # tel
            contact_point = FHIR::ContactPoint.new
            contact_point.system = :phone
            contact_point.value = telephone_record[:medical_institution_tel]
            organization.telecom << contact_point

            # fax
            contact_point = FHIR::ContactPoint.new
            contact_point.system = :fax
            contact_point.value = telephone_record[:medical_institution_fax]
            organization.telecom << contact_point
        end

        entry = FHIR::Bundle::Entry.new
        entry.resource = organization
        [entry]
    end
end