require_relative 'orca_generate_abstract'

class OrcaGenerateCommunication < OrcaGenerateAbstract
    def perform()
        results = []

        # 備考
        if get_orcadata["Memo"].present? || get_orcadata["Memo2"].present?
            communication = FHIR::Communication.new
            communication.id = SecureRandom.uuid
            communication.status = :unknown
            communication.category = create_codeable_concept('1', '処方箋備考', 'LC')

            [get_orcadata["Memo"], get_orcadata["Memo2"]].flatten.compact.reject(&:empty?).each do |memo|
                extension = FHIR::Extension.new
                extension.url = "http://hl7fhir.jp/fhir/StructureDefinition/Extension-JPCore-xxx"
                extension.valueString = memo
                communication.extension << extension
            end

            entry = FHIR::Bundle::Entry.new
            entry.resource = communication
            results << entry
        end

        # 残薬確認区分
        if get_orcadata["Check_Leftover_Class"].present?
            communication = FHIR::Communication.new
            communication.id = SecureRandom.uuid
            communication.status = :unknown
            communication.category = create_codeable_concept('3', '残確確認指示', 'LC')

            extension = FHIR::Extension.new
            extension.url = "http://hl7fhir.jp/fhir/StructureDefinition/Extension-JPCore-xxx"
            extension.valueCodeableConcept = create_codeable_concept(
                get_orcadata["Check_Leftover_Class"],
                case get_orcadata["Check_Leftover_Class"]
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

        get_composition.resource.section.first.entry.concat results.map{|entry|create_reference(entry.resource)}
        results
    end
end