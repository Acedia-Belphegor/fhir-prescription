require_relative 'qr_fhir_abstract_generator'

class QrFhirPrescriptionGenerator < QrFhirAbstractGenerator
    def perform()
        @bundle.entry.concat(QrGenerateComposition.new(get_params).perform) # Composition
        @bundle.entry.concat(QrGeneratePatient.new(get_params).perform) # Patient
        @bundle.entry.concat(QrGenerateOrganization.new(get_params).perform) # Organization
        @bundle.entry.concat(QrGeneratePractitioner.new(get_params).perform) # Practitioner
        @bundle.entry.concat(QrGeneratePractitionerRole.new(get_params).perform) # PractitionerRole
        @bundle.entry.concat(QrGenerateCoverage.new(get_params).perform) # Coverage
        @bundle.entry.concat(QrGenerateCommunication.new(get_params).perform) # Communication
        @bundle.entry.concat(QrGenerateMedicationRequest.new(get_params).perform) # MedicationRequest
        self
    end

    private
    def validation()
        # raise 'reject message, incorrect [MSH-9.MessageType]' unless validate_message_type('RDE','O11')
        true
    end
end