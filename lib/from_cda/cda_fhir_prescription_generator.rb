require_relative 'cda_fhir_abstract_generator'

class CdaFhirPrescriptionGenerator < CdaFhirAbstractGenerator
    def perform()
        @bundle.entry.concat(CdaGenerateComposition.new(get_params).perform) # Composition
        @bundle.entry.concat(CdaGeneratePatient.new(get_params).perform) # Patient
        @bundle.entry.concat(CdaGenerateOrganization.new(get_params).perform) # Organization
        @bundle.entry.concat(CdaGeneratePractitioner.new(get_params).perform) # Practitioner
        @bundle.entry.concat(CdaGeneratePractitionerRole.new(get_params).perform) # PractitionerRole
        @bundle.entry.concat(CdaGenerateCoverage.new(get_params).perform) # Coverage
        @bundle.entry.concat(CdaGenerateMedicationRequest.new(get_params).perform) # MedicationRequest
        CdaGenerateCompositionSections.new(get_params).perform # Composition.section
        self
    end

    private
    def validation()
        # raise 'reject message, incorrect [MSH-9.MessageType]' unless validate_message_type('RDE','O11')
        true
    end
end