require 'moji'
require_relative 'sips_generate_abstract'

class SipsGeneratePractitioner < SipsGenerateAbstract
    def perform()
        [generate_doctor_resource, generate_pharmacist_resource].flatten
    end

    # 医師リソース生成
    def generate_doctor_resource()
        prescription_record = get_records(PRESCRIPTION)&.first
        return unless prescription_record.present?
        results = []

        # Practitioner
        practitioner = FHIR::Practitioner.new
        practitioner.id = SecureRandom.uuid

        # 医師コード
        practitioner.identifier << build_identifier(prescription_record[:doctor_code], 'urn:oid:1.2.392.100495.20.3.41')

        # 医師漢字氏名
        if prescription_record[:doctor_kanji_name].present?
            human_name = FHIR::HumanName.new
            human_name.use = :official
            names = prescription_record[:doctor_kanji_name].split(/\p{blank}/)
            if names.length == 2
                human_name.family = names.first
                human_name.given << names.last
            else
                human_name.text = names.join
            end
            extension = FHIR::Extension.new
            extension.url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-representation"
            extension.valueCode = :IDE # 漢字
            human_name.extension << extension
            practitioner.name << human_name
        end

        # 医師カナ氏名
        if prescription_record[:doctor_kana_name].present?
            human_name = FHIR::HumanName.new
            human_name.use = :official
            names = Moji.han_to_zen(prescription_record[:doctor_kana_name]).split(/\p{blank}/)
            if names.length == 2
                human_name.family = names.first
                human_name.given << names.last
            else
                human_name.text = names.join
            end
            extension = FHIR::Extension.new
            extension.url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-representation"
            extension.valueCode = :SYL # カナ
            human_name.extension << extension
            practitioner.name << human_name
        end

        # 麻薬施用者免許番号
        if prescription_record[:narcotic_use_licence_number].present?
            qualification = FHIR::Practitioner::Qualification.new
            qualification.identifier = build_identifier(prescription_record[:narcotic_use_licence_number], 'urn:oid:1.2.392.100495.20.3.32')
            practitioner.qualification << qualification
        end

        entry = FHIR::Bundle::Entry.new
        entry.resource = practitioner
        results << entry

        # PractitionerRole
        practitioner_role = FHIR::PractitionerRole.new
        practitioner_role.id = SecureRandom.uuid

        practitioner_role.code << build_codeable_concept('doctor','Doctor','http://terminology.hl7.org/CodeSystem/practitioner-role') # 医師
        practitioner_role.practitioner = build_reference(practitioner)

        organization = get_resources_from_type('Organization').find{|r|r.identifier.select{|i|i.system == 'urn:oid:1.2.392.100495.20.3.22'}.map{|i|i.value}.include? '1'}
        practitioner_role.organization = build_reference(organization) if organization.present?

        # composition = get_composition.resource
        # composition.author << build_reference(practitioner_role)

        entry = FHIR::Bundle::Entry.new
        entry.resource = practitioner_role
        results << entry
    end

    # 薬剤師リソース生成
    def generate_pharmacist_resource()
        prescription_record = get_records(PRESCRIPTION)&.first
        return unless prescription_record.present?
        results = []

        # Practitioner
        practitioner = FHIR::Practitioner.new
        practitioner.id = SecureRandom.uuid

        # 薬剤師コード
        practitioner.identifier << build_identifier(prescription_record[:pharmacist_code], 'urn:oid:1.2.392.100495.20.3.43')

        # 薬剤師名
        if prescription_record[:pharmacist_name].present?
            human_name = FHIR::HumanName.new
            human_name.use = :official
            names = prescription_record[:pharmacist_name].split(/\p{blank}/)
            if names.length == 2
                human_name.family = names.first
                human_name.given << names.last
            else
                human_name.text = names.join
            end
            extension = FHIR::Extension.new
            extension.url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-representation"
            extension.valueCode = :IDE # 漢字
            human_name.extension << extension
            practitioner.name << human_name
        end

        entry = FHIR::Bundle::Entry.new
        entry.resource = practitioner
        results << entry

        # PractitionerRole
        practitioner_role = FHIR::PractitionerRole.new
        practitioner_role.id = SecureRandom.uuid

        practitioner_role.code << build_codeable_concept('pharmacist','Pharmacist','http://terminology.hl7.org/CodeSystem/practitioner-role') # 薬剤師
        practitioner_role.practitioner = build_reference(practitioner)

        organization = get_resources_from_type('Organization').find{|r|r.identifier.select{|i|i.system == 'urn:oid:1.2.392.100495.20.3.22'}.map{|i|i.value}.include? '4'}
        practitioner_role.organization = build_reference(organization) if organization.present?
        
        # composition = get_composition
        # composition.author << build_reference(practitioner_role)

        entry = FHIR::Bundle::Entry.new
        entry.resource = practitioner_role
        results << entry
    end
end