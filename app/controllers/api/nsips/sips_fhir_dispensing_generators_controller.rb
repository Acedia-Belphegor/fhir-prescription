require './lib/from_sips/sips_fhir_dispensing_generator'

class Api::Nsips::SipsFhirDispensingGeneratorsController < ApplicationController
    # POST：リクエストBODYに設定されたNSIPS(新調剤システム標準IF)のCSVをFHIR(json/xml)形式に変換して返す
    def create
        generator = SipsFhirDispensingGenerator.new(permitted_params)
        if generator.has_error?
            render json: { type: "nsips_to_fhir", errors: [generator.get_error] }, status: :bad_request and return
        end
        generator.perform
        respond_to do |format|
            format.json { render :json => generator.to_json }
            format.xml  { render :xml => generator.to_xml }
        end
    end

    def permitted_params
        params.require(:sips_fhir_dispensing_generator).permit(
            :encoding,
            :nsips
        )
    end
end