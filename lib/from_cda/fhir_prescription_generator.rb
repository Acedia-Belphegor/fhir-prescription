require_relative 'fhir_abstract_generator'

class FhirPrescriptionGenerator < FhirAbstractGenerator
    def perform()
        @bundle.entry.concat(GenerateComposition.new(get_params).perform) # Composition
        @bundle.entry.concat(GeneratePatient.new(get_params).perform) # Patient
        @bundle.entry.concat(GenerateOrganization.new(get_params).perform) # Organization
        @bundle.entry.concat(GeneratePractitioner.new(get_params).perform) # Practitioner
        @bundle.entry.concat(GeneratePractitionerRole.new(get_params).perform) # PractitionerRole
        @bundle.entry.concat(GenerateCoverage.new(get_params).perform) # Coverage
        @bundle.entry.concat(GenerateMedicationRequest.new(get_params).perform) # MedicationRequest
        GenerateCompositionSections.new(get_params).perform # Composition.section
        self
    end

    private
    def validation()
        # raise 'reject message, incorrect [MSH-9.MessageType]' unless validate_message_type('RDE','O11')
        true
    end
end