require_relative 'qr_generate_abstract'

class QrGenerateCommunication < QrGenerateAbstract
    def perform()
        results = []

        # 備考レコード
        record = get_records(81)&.first
        if record.present?
            communication = FHIR::Communication.new
            communication.id = SecureRandom.uuid
            communication.status = :unknown
            communication.category = create_codeable_concept('1', '処方箋備考', 'LC')

            extension = FHIR::Extension.new
            extension.url = "http://hl7fhir.jp/fhir/StructureDefinition/Extension-JPCore-xxx"
            extension.valueString = record[:remarks]
            communication.extension << extension

            entry = FHIR::Bundle::Entry.new
            entry.resource = communication
            results << entry
        end

        # 残薬確認欄レコード
        record = get_records(62)&.first
        if record.present?
            communication = FHIR::Communication.new
            communication.id = SecureRandom.uuid
            communication.status = :unknown
            communication.category = create_codeable_concept('3', '残確確認指示', 'LC')

            extension = FHIR::Extension.new
            extension.url = "http://hl7fhir.jp/fhir/StructureDefinition/Extension-JPCore-xxx"
            extension.valueCodeableConcept = create_codeable_concept(
                record[:confirm_remaining_medicine],
                case record[:confirm_remaining_medicine]
                when '1' then '疑義照会の上調剤'
                when '2' then '情報提供'
                end,
                'urn:oid:1.2.392.100495.20.2.42'
            )
            communication.extension << extension

            entry = FHIR::Bundle::Entry.new
            entry.resource = communication
            results << entry
        end

        get_composition.section.first.entry.concat results.map{|entry|create_reference(entry.resource)}
        results
    end
end