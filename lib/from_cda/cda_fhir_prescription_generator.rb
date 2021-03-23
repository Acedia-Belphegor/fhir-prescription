require_relative 'cda_fhir_abstract_generator'

class CdaFhirPrescriptionGenerator < CdaFhirAbstractGenerator
  def perform()
    @bundle.entry.concat(CdaGenerateComposition.new(get_params).perform) # Composition
    @bundle.entry.concat(CdaGeneratePatient.new(get_params).perform) # Patient
    @bundle.entry.concat(CdaGenerateEncounter.new(get_params).perform) # Encounter
    @bundle.entry.concat(CdaGenerateOrganization.new(get_params).perform) # Organization
    @bundle.entry.concat(CdaGeneratePractitioner.new(get_params).perform) # Practitioner
    @bundle.entry.concat(CdaGeneratePractitionerRole.new(get_params).perform) # PractitionerRole
    @bundle.entry.concat(CdaGenerateCoverage.new(get_params).perform) # Coverage
    @bundle.entry.concat(CdaGenerateCommunication.new(get_params).perform) # Communication
    @bundle.entry.concat(CdaGenerateMedicationRequest.new(get_params).perform) # MedicationRequest
    GenerateSignature.new(@bundle).perform # Signature
    self
  end

  private
  def validation()
    nil
  end
end