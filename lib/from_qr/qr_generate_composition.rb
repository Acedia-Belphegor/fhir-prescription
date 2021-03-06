require_relative 'qr_generate_abstract'

class QrGenerateComposition < QrGenerateAbstract
  def perform()
    composition = FHIR::Composition.new
    composition.id = SecureRandom.uuid
    composition.status = :final
    composition.type = build_codeable_concept('01', '処方箋', 'urn:oid:1.2.392.100495.20.2.11')
    composition.category << build_codeable_concept('01', '一般処方箋', build_url(:code_system, 'PrescriptionCategory'))
    composition.date = Time.current
    composition.title = '処方箋'
    composition.confidentiality = 'N'

    period = FHIR::Period.new
    # 処方箋交付年月日レコード
    delivery_record = get_records(51)&.first
    if delivery_record.present?
      period.start = Date.parse(delivery_record[:delivery_date])
    end
    # 使用期限年月日レコード
    expiration_record = get_records(52)&.first
    if expiration_record.present?
      period.end = Date.parse(expiration_record[:expiration_date])
    end
    event = FHIR::Composition::Event.new
    event.period = period
    composition.event = event

    # 処方箋番号レコード
    prescription_number_record = get_records(82)&.first
    if prescription_number_record.present?
      composition.identifier = build_identifier(prescription_number_record[:prescription_number], 'urn:oid:1.2.392.100495.20.3.11')
    end

    section = FHIR::Composition::Section.new
    section.title = '処方情報'
    section.code = build_codeable_concept('01', '処方情報', 'urn:oid:1.2.392.100495.20.2.12')
    composition.section << section

    # 文書のバージョン
    extension = FHIR::Extension.new
    extension.url = build_url(:structure_definition, 'composition-clinicaldocument-versionNumber')
    extension.valueString = "1.0"
    composition.extension << extension

    [build_entry(composition)]
  end
end