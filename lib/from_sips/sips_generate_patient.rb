require 'moji'
require_relative 'sips_generate_abstract'

class SipsGeneratePatient < SipsGenerateAbstract
    def perform()
        patient_record = get_records(PATIENT)&.first
        return unless patient_record.present?

        patient = FHIR::Patient.new
        patient.id = SecureRandom.uuid

        # 患者コード
        patient.identifier = generate_identifier(patient_record[:patient_code], "urn:oid:1.2.392.100495.20.3.51.1")

        # 患者カナ氏名
        if patient_record[:kana_name].present?
            human_name = FHIR::HumanName.new
            human_name.use = :official
            names = Moji.han_to_zen(patient_record[:kana_name]).split(/\p{blank}/)
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
            patient.name << human_name
        end

        # 患者漢字氏名
        if patient_record[:kanji_name].present?
            human_name = FHIR::HumanName.new
            human_name.use = :official
            names = patient_record[:kanji_name].split(/\p{blank}/)
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
            patient.name << human_name
        end

        # 患者性別
        patient.gender = case patient_record[:gender]
                         when '1' then :male
                         when '2' then :female
                         end
        
        # 生年月日
        patient.birthDate = Date.parse(patient_record[:birth_date])

        address = FHIR::Address.new
        address.line << patient_record[:address] # 住所
        address.postalCode = patient_record[:postal_code] # 郵便番号
        patient.address << address

        contacts = [
            { system: :phone, use: :home, value: patient_record[:home_phone] }, # 自宅電話番号
            { system: :phone, use: :work, value: patient_record[:work_phone] }, # 勤務先電話番号
            { system: :phone, use: :mobile, value: patient_record[:emergency_phone] }, # 緊急連絡先
            { system: :email, use: nil, value: patient_record[:email] }, # メールアドレス
        ]
        contacts.select{|contact|contact[:value].present?}.each{|contact|
            contact_point = FHIR::ContactPoint.new
            contact_point.system = contact[:system]
            contact_point.use = contact[:use]
            contact_point.value = contact[:value]
            patient.telecom << contact_point
        }

        composition = get_composition.resource
        composition.subject = create_reference(patient)

        entry = FHIR::Bundle::Entry.new
        entry.resource = patient
        [entry]
    end
end