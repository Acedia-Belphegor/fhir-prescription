require_relative 'orca_generate_abstract'

class OrcaGeneratePractitioner < OrcaGenerateAbstract
    def perform()
        # ドクター情報
        orca_doctor = get_orcadata["Doctor"]
        return unless orca_doctor.present?

        practitioner = FHIR::Practitioner.new
        practitioner.id = SecureRandom.uuid

        # ドクターコード
        practitioner.identifier << create_identifier(orca_doctor["Code"], 'urn:oid:1.2.392.100495.20.3.41.1')

        # ドクター名
        if orca_doctor["Name"].present?
            human_name = FHIR::HumanName.new
            human_name.use = :official
            names = orca_doctor["Name"].split(/\p{blank}/)
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
            practitioner.name << human_name
        end

        # ドクターカナ名
        if orca_doctor["KanaName"].present?
            human_name = FHIR::HumanName.new
            human_name.use = :official
            names = orca_doctor["KanaName"].split(/\p{blank}/)
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
            practitioner.name << human_name
        end

        # 麻薬施行者免許証番号
        if orca_doctor["Drug_Permission_ID"].present?
            qualification = FHIR::Practitioner::Qualification.new
            qualification.identifier = create_identifier(orca_doctor["Drug_Permission_ID"], 'urn:oid:1.2.392.100495.20.3.32')
            practitioner.qualification << qualification
        end

        entry = FHIR::Bundle::Entry.new
        entry.resource = practitioner
        [entry]
    end
end