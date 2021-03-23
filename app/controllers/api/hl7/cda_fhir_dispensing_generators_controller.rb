require './lib/from_cda/cda_fhir_dispensing_generator'

class Api::Hl7::CdaFhirDispensingGeneratorsController < ApplicationController
  # POST：リクエストBODYに設定されたHL7CDAをFHIR(json/xml)形式に変換して返す
  def create        
    generator = CdaFhirDispensingGenerator.new(permitted_params).perform
    respond_to do |format|
      format.json { render :json => generator.to_json }
      format.xml  { render :xml => generator.to_xml }
    end
  end

  def permitted_params
    params.require(:cda_fhir_dispensing_generator).permit(
      :encoding,
      :document
    )
  end
end