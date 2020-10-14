require_relative 'sips_fhir_abstract_generator'

class SipsFhirDispensingGenerator < SipsFhirAbstractGenerator
    def perform()
        @bundle.entry.concat(SipsGenerateComposition.new(get_params).perform) # Composition
        @bundle.entry.concat(SipsGeneratePatient.new(get_params).perform) # Patient
        @bundle.entry.concat(SipsGenerateOrganization.new(get_params).perform) # Organization
        @bundle.entry.concat(SipsGeneratePractitioner.new(get_params).perform) # Practitioner
        @bundle.entry.concat(SipsGenerateCoverage.new(get_params).perform) # Coverage
        @bundle.entry.concat(SipsGenerateMedicationDispense.new(get_params).perform) # MedicationDispense
        self
    end

    private
    def validation()
        nil
    end
end