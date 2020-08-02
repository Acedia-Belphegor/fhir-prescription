require_relative 'v2_fhir_abstract_generator'

class V2FhirPrescriptionGenerator < V2FhirAbstractGenerator
    def perform()
        @bundle.entry.concat(V2GenerateComposition.new(get_params).perform) # Composition
        @bundle.entry.concat(V2GeneratePatient.new(get_params).perform) # Patient
        @bundle.entry.concat(V2GenerateOrganization.new(get_params).perform) # Organization
        @bundle.entry.concat(V2GeneratePractitioner.new(get_params).perform) # Practitioner
        @bundle.entry.concat(V2GeneratePractitionerRole.new(get_params).perform) # PractitionerRole
        @bundle.entry.concat(V2GenerateCoverage.new(get_params).perform) # Coverage
        @bundle.entry.concat(V2GenerateMedicationRequest.new(get_params).perform) # MedicationRequest
        self
    end

    private
    def validation()
        # raise 'reject message, incorrect [MSH-9.MessageType]' unless validate_message_type('RDE','O11')
        true
    end
end