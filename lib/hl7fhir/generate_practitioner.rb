require_relative 'generate_abstract'

class GeneratePractitioner < GenerateAbstract
    def perform()
        practitioner = FHIR::Practitioner.new
        practitioner.id = SecureRandom.uuid

        assigned_author = get_clinical_document.xpath('author/assignedAuthor')
        return unless assigned_author.present?

        assigned_author.xpath('id').each do |id|
            identifier = generate_identifier(id)

            if identifier.system.match(/^1.2.392.100495.20.3.(?=.*31)|(?=.*32)|(?=.*33).*$/).present?
                qualification = FHIR::Practitioner::Qualification.new
                qualification.identifier = identifier
                practitioner.qualification << qualification
            else
                practitioner.identifier << identifier
            end
        end

        assigned_author.xpath('assignedPerson/name').each{ |name| practitioner.name << generate_human_name(name) }

        entry = FHIR::Bundle::Entry.new
        entry.resource = practitioner
        [entry]
    end
end