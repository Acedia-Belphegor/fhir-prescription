require './lib/from_cda/cda_fhir_prescription_generator'

class Api::Hl7::CdaFhirPrescriptionGeneratorsController < ApplicationController
    # POST：リクエストBODYに設定されたHL7CDAをFHIR(json/xml)形式に変換して返す
    def create        
        generator = CdaFhirPrescriptionGenerator.new(permitted_params)
        if generator.has_error?
            render json: { type: "hl7cda_to_fhir", errors: [generator.get_error] }, status: :bad_request and return
        end
        generator.perform
        respond_to do |format|
            format.json { render :json => generator.get_resources.to_json }
            format.xml  { render :xml => generator.get_resources.to_xml }
        end
    end

    def permitted_params
        params.require(:cda_fhir_prescription_generator).permit(
            :encoding,
            :document
        )
    end
end