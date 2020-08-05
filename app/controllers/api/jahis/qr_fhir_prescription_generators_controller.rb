require './lib/from_qr/qr_fhir_prescription_generator'

class Api::Jahis::QrFhirPrescriptionGeneratorsController < ApplicationController
    # POST：リクエストBODYに設定されたJAHIS院外処方箋２次元シンボル記録条件規約のCSVをFHIR(json/xml)形式に変換して返す
    def create
        generator = QrFhirPrescriptionGenerator.new(permitted_params).perform
        respond_to do |format|
            format.json { render :json => generator.get_resources.to_json }
            format.xml  { render :xml => generator.get_resources.to_xml }
        end
    end

    def permitted_params
        params.require(:qr_fhir_prescription_generator).permit(
            :encoding,
            :qr_code
        )
    end
end