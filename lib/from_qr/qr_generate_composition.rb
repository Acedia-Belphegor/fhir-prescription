require_relative 'qr_generate_abstract'

class QrGenerateComposition < QrGenerateAbstract
    def perform()
        composition = FHIR::Composition.new
        composition.id = SecureRandom.uuid
        composition.status = :final
        composition.type = create_codeable_concept('01', '処方箋', 'urn:oid:1.2.392.100495.20.2.11')
        composition.date = DateTime.now
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
            composition.identifier = create_identifier(prescription_number_record[:prescription_number], 'urn:oid:1.2.392.100495.20.3.11')
        end

        section = FHIR::Composition::Section.new
        section.title = '処方指示ヘッダ'
        section.code = create_codeable_concept('01', '処方指示ヘッダ', 'TBD')
        composition.section << section

        entry = FHIR::Bundle::Entry.new
        entry.resource = composition
        [entry]
    end
end