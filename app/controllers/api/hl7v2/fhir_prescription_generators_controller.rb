require './lib/from_v2/fhir_prescription_generator'

class Api::Hl7v2::FhirPrescriptionGeneratorsController < ApplicationController
    # POST：リクエストBODYに設定されたHL7v2メッセージをFHIR(json/xml)形式に変換して返す
    def create
        generator = FhirPrescriptionGenerator.new(permitted_params).perform
        respond_to do |format|
            format.json { render :json => generator.get_resources.to_json }
            format.xml  { render :xml => generator.get_resources.to_xml }
        end
    end

    def permitted_params
        params.require(:fhir_prescription_generator).permit(
            :prefecture_code,
            :medical_fee_point_code,
            :medical_institution_code,
            :message,
        )
      end
end