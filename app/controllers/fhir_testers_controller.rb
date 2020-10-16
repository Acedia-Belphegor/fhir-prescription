require "base64"
require './lib/from_cda/cda_fhir_prescription_generator'
require './lib/from_v2/v2_fhir_prescription_generator'
require './lib/from_qr/qr_fhir_prescription_generator'
require './lib/from_sips/sips_fhir_dispensing_generator'

class FhirTestersController < ApplicationController
    def index
        render "index"
    end

    def create
        generator = case params[:type]
                    when 'hl7cda_to_fhir'
                        from_cda
                    when 'hl7v2_to_fhir'
                        from_v2
                    when 'jahisqr_to_fhir'
                        from_qr
                    when 'nsips_to_fhir'
                        from_sips
                    end

        if generator.has_error?
            render json: { type: params[:type], errors: [generator.get_error] }, status: :bad_request and return
        end

        generator.perform
            
        if params[:format] == 'xml'
            render xml: generator.get_resources.to_xml
        else
            render json: generator.get_resources.to_json
        end
    end

    def from_cda()
        cda_params = {
            encoding: "UTF-8", 
            document: Base64.encode64(params[:data])
        }
        CdaFhirPrescriptionGenerator.new(cda_params)
    end

    def from_v2()
        v2_params = {
            encoding: "UTF-8",
            prefecture_code: "13",
            medical_fee_point_code: "1",
            medical_institution_code: "9999999",
            message: Base64.encode64(params[:data])
        }
        V2FhirPrescriptionGenerator.new(v2_params)
    end

    def from_qr()
        qr_params = {
            encoding: "UTF-8", 
            qr_code: Base64.encode64(params[:data])
        }
        QrFhirPrescriptionGenerator.new(qr_params)
    end

    def from_sips()
        sips_params = {
            encoding: "UTF-8", 
            nsips: Base64.encode64(params[:data])
        }
        SipsFhirDispensingGenerator.new(sips_params)
    end
end