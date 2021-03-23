require './lib/from_v2/v2_fhir_prescription_generator'

class Api::Hl7::V2FhirPrescriptionGeneratorsController < ApplicationController
  # POST：リクエストBODYに設定されたHL7v2メッセージをFHIR(json/xml)形式に変換して返す
  def create
    generator = V2FhirPrescriptionGenerator.new(permitted_params)
    if generator.has_error?
      render json: { type: "hl7v2_to_fhir", errors: [generator.get_error] }, status: :bad_request and return
    end
    generator.perform
    respond_to do |format|
      format.json { render :json => generator.to_json }
      format.xml  { render :xml => generator.to_xml }
    end
  end

  def permitted_params
    params.require(:v2_fhir_prescription_generator).permit(
      :encoding,
      :prefecture_code,
      :medical_fee_point_code,
      :medical_institution_code,
      :message
    )
  end
end