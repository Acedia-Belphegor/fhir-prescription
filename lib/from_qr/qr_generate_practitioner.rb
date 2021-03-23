require_relative 'qr_generate_abstract'

class QrGeneratePractitioner < QrGenerateAbstract
  def perform()
    practitioner = FHIR::Practitioner.new
    practitioner.id = SecureRandom.uuid

    # 医師レコード
    doctor_record = get_records(5)&.first
    return [] unless doctor_record.present?

    # 医師コード
    practitioner.identifier << create_identifier(doctor_record[:doctor_code], 'urn:oid:1.2.392.100495.20.3.41.1')

    # 医師漢字氏名
    if doctor_record[:doctor_kanji_name].present?
      human_name = FHIR::HumanName.new
      human_name.use = :official
      human_name.text = doctor_record[:doctor_kanji_name]
      names = human_name.text.split(/\p{blank}/)
      if names.length > 1
        human_name.family = names.first
        human_name.given = names[1..-1]
      end
      extension = FHIR::Extension.new
      extension.url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-representation"
      extension.valueCode = :IDE # 漢字
      human_name.extension << extension
      practitioner.name << human_name
    end

    # 医師カナ氏名
    if doctor_record[:doctor_kana_name].present?
      human_name = FHIR::HumanName.new
      human_name.use = :official
      human_name.text = doctor_record[:doctor_kana_name]
      names = human_name.text.split(/\p{blank}/)
      if names.length > 1
        human_name.family = names.first
        human_name.given = names[1..-1]
      end
      extension = FHIR::Extension.new
      extension.url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-representation"
      extension.valueCode = :SYL # カナ
      human_name.extension << extension
      practitioner.name << human_name
    end

    # 麻薬施用レコード
    narcotic_record = get_records(61)&.first
    if narcotic_record.present?
      qualification = FHIR::Practitioner::Qualification.new
      qualification.identifier = create_identifier(narcotic_record[:narcotic_use_licence_number], 'urn:oid:1.2.392.100495.20.3.32')
      qualification.code = create_codeable_concept('NarcoticsPractitioner', nil, create_url(:code_system, 'Certificate'))
      practitioner.qualification << qualification
    end

    get_composition.author << create_reference(practitioner)

    [create_entry(practitioner)]
  end
end