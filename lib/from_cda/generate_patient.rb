require_relative 'generate_abstract'

class GeneratePatient < GenerateAbstract
    def perform()
        patient = FHIR::Patient.new
        patient.id = SecureRandom.uuid

        patient_role = get_clinical_document.xpath('recordTarget/patientRole')
        return unless patient_role.present?

        patient.identifier = patient_role.xpath('id').map{ |id| generate_identifier(id) }
        patient.name = patient_role.xpath('patient/name').map{ |name| generate_human_name(name) }
        patient.birthDate = Date.parse(patient_role.xpath('patient/birthTime/@value').text)
        patient.gender = 
            case patient_role.xpath('patient/administrativeGenderCode/@code').text
            when 'M' then :male
            when 'F' then :female
            when 'UN' then :unknown
            end
        patient.address = patient_role.xpath('addr').map{ |addr| generate_address(addr) }
        patient.telecom = patient_role.xpath('telecom').map{ |telecom| generate_contact_point(telecom) }

        composition = get_composition.resource
        composition.subject = create_reference(patient)

        entry = FHIR::Bundle::Entry.new
        entry.resource = patient
        [entry]
    end
end