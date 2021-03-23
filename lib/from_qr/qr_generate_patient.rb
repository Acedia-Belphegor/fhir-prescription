require 'moji'
require_relative 'qr_generate_abstract'

class QrGeneratePatient < QrGenerateAbstract
    def perform()
      patient = FHIR::Patient.new
      patient.id = SecureRandom.uuid

      # 患者氏名レコード
      patient_record = get_records(11)&.first
      return unless patient_record.present?

      # 患者コード
      if patient_record[:patient_code].present?
        patient.identifier = create_identifier(patient_record[:patient_code], "urn:oid:1.2.392.100495.20.3.51.1")
      end

      # 患者漢字氏名
      if patient_record[:patient_kanji_name].present?
        human_name = FHIR::HumanName.new
        human_name.use = :official
        human_name.text = patient_record[:patient_kanji_name]
        names = human_name.text.split(/\p{blank}/)
        if names.length > 1
          human_name.family = names.first
          human_name.given = names[1..-1]
        end
        extension = FHIR::Extension.new
        extension.url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-representation"
        extension.valueCode = :IDE # 漢字
        human_name.extension << extension
        patient.name << human_name
      end

      # 患者カナ氏名
      if patient_record[:patient_kana_name].present?
        human_name = FHIR::HumanName.new
        human_name.use = :official
        human_name.text = Moji.han_to_zen(patient_record[:patient_kana_name])
        names = human_name.text.split(/\p{blank}/)
        if names.length > 1
          human_name.family = names.first
          human_name.given = names[1..-1]
        end
        extension = FHIR::Extension.new
        extension.url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-representation"
        extension.valueCode = :SYL # カナ
        human_name.extension << extension
        patient.name << human_name
      end

      # 患者性別レコード
      gender_record = get_records(12)&.first
      return unless gender_record.present?

      # 患者性別
      patient.gender = case gender_record[:patient_gender]
                       when '1' then :male
                       when '2' then :female
                       end
        
      # 患者生年月日レコード
      birthdate_record = get_records(13)&.first
      return unless birthdate_record.present?

      # 生年月日
      patient.birthDate = Date.parse(birthdate_record[:patient_birthdate])

      # 麻薬処方レコード
      narcotic_record = get_records(61)&.first
      if narcotic_record.present?
        # 麻薬施用患者住所
        address = FHIR::Address.new
        address.text = narcotic_record[:narcotic_use_patient_address]
        patient.address << address

        # 麻薬施用患者電話番号
        contact_point = FHIR::ContactPoint.new
        contact_point.system = :phone
        contact_point.value = narcotic_record[:narcotic_use_patient_tel]
        patient.telecom << contact_point
      end

      get_composition.subject = create_reference(patient)

      [create_entry(patient)]
    end
end