require_relative 'v2_generate_abstract'

class V2GenerateComposition < V2GenerateAbstract
  def perform()
    composition = FHIR::Composition.new
    composition.id = SecureRandom.uuid

    msh_segment = get_segments('MSH')&.first
    return unless msh_segment.present?

    composition.status = :final
    composition.type = create_codeable_concept('01', '処方箋', 'urn:oid:1.2.392.100495.20.2.11')
    composition.category << create_codeable_concept('01', '一般処方箋', create_url(:code_system, 'PrescriptionCategory'))
    composition.date = Time.zone.parse(msh_segment[:datetime_of_message].first[:time])
    composition.title = '処方箋'
    composition.confidentiality = 'N'

    orc_segment = get_segments('ORC')&.first
    if orc_segment.present?
      period = FHIR::Period.new
      # ORC-9.トランザクション日時(交付年月日)
      period.start = Date.parse(orc_segment[:datetime_of_transaction].first[:time]) if orc_segment[:datetime_of_transaction].present?
      event = FHIR::Composition::Event.new
      event.period = period
      composition.event = event
    end

    rxe_segment = get_segments('RXE')&.first
    if rxe_segment.present?
      # RXE-15.処方箋番号
      composition.identifier = generate_identifier(rxe_segment[:prescription_number], 'urn:oid:1.2.392.100495.20.3.11') if rxe_segment[:prescription_number].present?
    end

    section = FHIR::Composition::Section.new
    section.title = '処方情報'
    section.code = create_codeable_concept('01', '処方情報', 'urn:oid:1.2.392.100495.20.2.12')
    composition.section << section

    # 文書のバージョン
    extension = FHIR::Extension.new
    extension.url = create_url(:structure_definition, 'composition-clinicaldocument-versionNumber')
    extension.valueString = "1.0"
    composition.extension << extension

    [create_entry(composition)]
  end
end