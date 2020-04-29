require_relative 'generate_abstract'

class GeneratePatient < GenerateAbstract
    def perform()
        patient = FHIR::Patient.new
        patient.id = SecureRandom.uuid

        patient_role = get_clinical_document.xpath('recordTarget/patientRole')
        return unless patient_role.present?

        patient_role.xpath('id').each{ |id| patient.identifier << generate_identifier(id) }
        patient_role.xpath('patient/name').each{ |name| patient.name << generate_human_name(name) }
        patient.birthDate = Date.parse(patient_role.xpath('patient/birthTime/@value').text)
        patient.gender = 
            case patient_role.xpath('patient/administrativeGenderCode/@code').text
            when 'M' then :male
            when 'F' then :female
            when 'UN' then :unknown
            end
        patient_role.xpath('addr').each{ |addr| patient.address << generate_address(addr) }
        patient_role.xpath('telecom').each{ |telecom| patient.telecom << generate_contact_point(telecom) }

        composition = get_composition.resource
        composition.subject = create_reference(patient)

        entry = FHIR::Bundle::Entry.new
        entry.resource = patient
        [entry]
    end
end