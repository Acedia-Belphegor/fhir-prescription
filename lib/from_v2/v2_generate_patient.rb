require_relative 'v2_generate_abstract'

class V2GeneratePatient < V2GenerateAbstract
    def perform()
        pid_segment = get_segments('PID')&.first
        return [] unless pid_segment.present?

        patient = FHIR::Patient.new
        patient.id = SecureRandom.uuid

        patient.identifier = pid_segment[:patient_identifier_list].map{|element|generate_identifier(element[:id_number], "urn:oid:1.2.392.100495.20.3.51.1")}
        patient.name = pid_segment[:patient_name].map{|element|generate_human_name(element)}
        patient.birthDate = Date.parse(pid_segment[:datetime_of_birth].first[:time])
        patient.gender = case pid_segment[:administrative_sex]
                         when 'M' then :male
                         when 'F' then :female
                         when 'U' then :unknown
                         end
        patient.address = pid_segment[:patient_address].map{|addr|generate_address(addr)} if pid_segment[:patient_address].present?
        patient.telecom.concat pid_segment[:phone_number_home].map{|telecom|generate_contact_point(telecom)} if pid_segment[:phone_number_home].present?
        patient.telecom.concat pid_segment[:phone_number_business].map{|telecom|generate_contact_point(telecom)} if pid_segment[:phone_number_business].present?

        composition = get_composition.resource
        composition.subject = create_reference(patient)

        entry = FHIR::Bundle::Entry.new
        entry.resource = patient
        [entry]
    end
end