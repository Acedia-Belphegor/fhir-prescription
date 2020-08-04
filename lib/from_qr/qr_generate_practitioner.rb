require_relative 'qr_generate_abstract'

class QrGeneratePractitioner < QrGenerateAbstract
    def perform()
        practitioner = FHIR::Practitioner.new
        practitioner.id = SecureRandom.uuid

        # 医師レコード
        doctor_record = get_records(5)&.first
        return unless doctor_record.present?

        # 医師コード
        practitioner.identifier << generate_identifier(doctor_record[:doctor_code], 'urn:oid:1.2.392.100495.20.3.41.1')

        # 医師漢字氏名
        if doctor_record[:doctor_kanji_name].present?
            human_name = FHIR::HumanName.new
            human_name.use = :official
            names = doctor_record[:doctor_kanji_name].split(/\p{blank}/)
            if names.length == 2
                human_name.family = names.first
                human_name.given << names.last
            else
                human_name.text = names.join
            end
            extension = FHIR::Extension.new
            extension.url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-representation"
            extension.valueCode = 'I' # 漢字
            human_name.extension << extension
            practitioner.name << human_name
        end

        # 医師カナ氏名
        if doctor_record[:doctor_kana_name].present?
            human_name = FHIR::HumanName.new
            human_name.use = :official
            names = doctor_record[:doctor_kana_name].split(/\p{blank}/)
            if names.length == 2
                human_name.family = names.first
                human_name.given << names.last
            else
                human_name.text = names.join
            end
            extension = FHIR::Extension.new
            extension.url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-representation"
            extension.valueCode = 'P' # カナ
            human_name.extension << extension
            practitioner.name << human_name
        end

        # 麻薬処方レコード
        narcotic_record = get_records(61)&.first
        if narcotic_record.present?
            qualification = FHIR::Practitioner::Qualification.new
            qualification.identifier = generate_identifier(narcotic_record[:narcotic_use_licence_number], 'urn:oid:1.2.392.100495.20.3.32')
            practitioner.qualification << qualification
        end

        entry = FHIR::Bundle::Entry.new
        entry.resource = practitioner
        [entry]
    end
end