require_relative 'cda_generate_abstract'

class CdaGeneratePractitioner < CdaGenerateAbstract
    def perform()
        practitioner = FHIR::Practitioner.new
        practitioner.id = SecureRandom.uuid

        assigned_author = get_clinical_document.xpath('author/assignedAuthor')
        return unless assigned_author.present?

        assigned_author.xpath('id').each do |id|
            identifier = generate_identifier(id)

            # 1.2.392.100495.20.3.31 -> 医籍登録番号
            # 1.2.392.100495.20.3.32 -> 麻薬施用者番号
            # 1.2.392.100495.20.3.33 -> 薬剤師名簿登録番号
            if identifier.system.match(/^urn:oid:1.2.392.100495.20.3.(?=31)|(?=32)|(?=33).*$/).present?
                qualification = FHIR::Practitioner::Qualification.new
                qualification.identifier = identifier
                practitioner.qualification << qualification
            else
                practitioner.identifier << identifier
            end
        end

        practitioner.name = assigned_author.xpath('assignedPerson/name').map{ |name| generate_human_name(name) }

        entry = FHIR::Bundle::Entry.new
        entry.resource = practitioner
        [entry]
    end
end