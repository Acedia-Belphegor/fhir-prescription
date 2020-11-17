require_relative 'orca_generate_abstract'

class OrcaGeneratePatient < OrcaGenerateAbstract
    def perform()
        # 患者情報
        orca_patient = get_orcadata["Patient"]
        return unless orca_patient.present?

        patient = FHIR::Patient.new
        patient.id = SecureRandom.uuid

        # 患者番号
        patient.identifier = create_identifier(orca_patient["ID"], "urn:oid:1.2.392.100495.20.3.51.1")

        # 患者氏名
        if orca_patient["Name"].present?
            human_name = FHIR::HumanName.new
            human_name.use = :official
            names = orca_patient["Name"].split(/\p{blank}/)
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

        # カナ氏名
        if orca_patient["KanaName"].present?
            human_name = FHIR::HumanName.new
            human_name.use = :official
            names = orca_patient["KanaName"].split(/\p{blank}/)
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

        # 性別
        patient.gender = case orca_patient["Sex"]
                         when '1' then :male
                         when '2' then :female
                         end

        # 誕生日
        patient.birthDate = Date.parse(orca_patient["BirthDate"])

        # 麻薬施用患者住所
        orca_memo = get_orcadata["Memo"].select{|memo|memo.start_with?("患者住所")}&.first
        if orca_memo.present?
            address = FHIR::Address.new
            address.line << orca_memo.gsub('患者住所：', '')
            patient.address << address
        end

        composition = get_composition.resource
        composition.subject = create_reference(patient)

        entry = FHIR::Bundle::Entry.new
        entry.resource = patient
        [entry]
    end
end