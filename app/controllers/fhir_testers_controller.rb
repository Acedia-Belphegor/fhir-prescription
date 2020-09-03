require "base64"
require './lib/from_cda/cda_fhir_prescription_generator'
require './lib/from_v2/v2_fhir_prescription_generator'
require './lib/from_qr/qr_fhir_prescription_generator'

class FhirTestersController < ApplicationController
    def index
        render "index"
    end

    def create
        generator = case params[:type]
                    when 'cda'
                        from_cda
                    when 'v2'
                        from_v2
                    when 'qr'
                        from_qr
                    end

        if params[:format] == 'xml'
            render xml: generator.get_resources.to_xml
        else
            render json: generator.get_resources.to_json
        end
    end

    def from_cda
        cda_params = {
            encoding: "UTF-8", 
            document: Base64.encode64(params[:data])
        }
        CdaFhirPrescriptionGenerator.new(cda_params).perform
    end

    def from_v2
        v2_params = {
            encoding: "UTF-8",
            prefecture_code: "13",
            medical_fee_point_code: "1",
            medical_institution_code: "9999999",
            message: Base64.encode64(params[:data])
        }
        V2FhirPrescriptionGenerator.new(v2_params).perform
    end

    def from_qr
        qr_params = {
            encoding: "UTF-8", 
            qr_code: Base64.encode64(params[:data])
        }
        QrFhirPrescriptionGenerator.new(qr_params).perform
    end
end