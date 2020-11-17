require_relative 'orca_fhir_abstract_generator'

class OrcaFhirPrescriptionGenerator < OrcaFhirAbstractGenerator
    def perform()
        @bundle.entry.concat(OrcaGenerateComposition.new(get_params).perform) # Composition
        @bundle.entry.concat(OrcaGeneratePatient.new(get_params).perform) # Patient
        @bundle.entry.concat(OrcaGenerateOrganization.new(get_params).perform) # Organization
        @bundle.entry.concat(OrcaGeneratePractitioner.new(get_params).perform) # Practitioner
        @bundle.entry.concat(OrcaGeneratePractitionerRole.new(get_params).perform) # PractitionerRole
        @bundle.entry.concat(OrcaGenerateCoverage.new(get_params).perform) # Coverage
        @bundle.entry.concat(OrcaGenerateCommunication.new(get_params).perform) # Communication
        @bundle.entry.concat(OrcaGenerateMedicationRequest.new(get_params).perform) # MedicationRequest
        self
    end

    private
    def validation()
        nil
    end
end
__END__
https://www.orca.med.or.jp/receipt/tec/api/report_print/shohosen.html
