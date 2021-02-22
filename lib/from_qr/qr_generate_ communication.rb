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
            communication.category = create_codeable_concept('1', '処方箋備考', create_url(:code_system, 'CommunicationCategory'))

            extension = FHIR::Extension.new
            extension.url = create_url(:structure_definition, 'CommunicationContent')
            extension.valueString = record[:remarks]
            communication.extension << extension

            results << create_entry(communication)
        end

        # 残薬確認欄レコード
        record = get_records(62)&.first
        if record.present?
            communication = FHIR::Communication.new
            communication.id = SecureRandom.uuid
            communication.status = :unknown
            communication.category = create_codeable_concept('3', '残薬確認指示', create_url(:code_system, 'CommunicationCategory'))

            extension = FHIR::Extension.new
            extension.url = create_url(:structure_definition, 'CommunicationContent')
            extension.valueCodeableConcept = create_codeable_concept(
                record[:confirm_remaining_medicine],
                case record[:confirm_remaining_medicine]
                when '1' then '疑義照会の上調剤'
                when '2' then '情報提供'
                end,
                'urn:oid:1.2.392.100495.20.2.42'
            )
            communication.extension << extension

            results << create_entry(communication)
        end

        # Section
        get_composition.section.first.entry.concat results.map{|entry|create_reference(entry.resource)}
        
        results
    end
end