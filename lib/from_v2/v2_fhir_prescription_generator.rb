require_relative 'v2_fhir_abstract_generator'
require_relative '../common/generate_signature'

class V2FhirPrescriptionGenerator < V2FhirAbstractGenerator
    def perform()
        @bundle.entry.concat(V2GenerateComposition.new(get_params).perform) # Composition
        @bundle.entry.concat(V2GeneratePatient.new(get_params).perform) # Patient
        @bundle.entry.concat(V2GenerateEncounter.new(get_params).perform) # Encounter
        @bundle.entry.concat(V2GenerateOrganization.new(get_params).perform) # Organization
        @bundle.entry.concat(V2GeneratePractitioner.new(get_params).perform) # Practitioner
        @bundle.entry.concat(V2GeneratePractitionerRole.new(get_params).perform) # PractitionerRole
        @bundle.entry.concat(V2GenerateCoverage.new(get_params).perform) # Coverage
        @bundle.entry.concat(V2GenerateMedicationRequest.new(get_params).perform) # MedicationRequest
        GenerateSignature.new(@bundle).perform # Signature
        self
    end

    private
    def validation()
        message = get_params[:message]

        # 必須セグメントチェック
        results = %w[MSH PID ORC RXE TQ1 RXR].map{|s|{segment: s, existed: s.in?(message.map{|f|f[:segment_id]})}}&.select{|r|!r[:existed]}
        if results.present?
            return { code: "segment_error", message: "Required segment does not exist (#{results.map{|r|r[:segment]}.join(",")})" }
        end

        msh_segment = message.select{|s|s[:segment_id] == "MSH"}&.first

        # MSH-9
        message_type = msh_segment[:message_type]&.first
        if message_type.present?
            # RDE^O11 以外は許容しない
            unless message_type[:message_code] == "RDE" && message_type[:trigger_event] == "O11"
                return { code: "field_error", message: "[MSH-9.MessageType] invalid values (#{message_type.values.join("^")})" }
            end
        else
            return { code: "field_error", message: "[MSH-9.MessageType] is null" }
        end

        nil
    end
end