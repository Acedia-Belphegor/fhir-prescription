require 'json'
require "base64"
require 'fhir_client'
require_relative 'qr_code_parser'

Dir[File.expand_path(File.dirname(__FILE__)) << '/qr_generate_*.rb'].each do |file|
    require file
end

class QrFhirAbstractGenerator
    def initialize(params)
        @params = params
        str = if Encoding.find(params[:encoding]) == Encoding::Shift_JIS
            Base64.decode64(params[:qr_code]).force_encoding("cp932").encode("utf-8")
        else
            Base64.decode64(params[:qr_code]).force_encoding("utf-8")
        end
        @qr_code = QrCodeParser.new(str).parse
        @error = validation
        @client = FHIR::Client.new("http://localhost:8080", default_format: 'json')
        @client.use_r4
        FHIR::Model.client = @client            
        @bundle = FHIR::Bundle.new
        @bundle.id = SecureRandom.uuid
        @bundle.type = :document
    end

    def perform()
        raise NotImplementedError.new("You must implement #{self.class}##{__method__}")
    end

    def get_resources()
        @bundle
    end

    def get_resources_from_type(resource_type)
        @bundle.entry.select{ |c| c.resource.resourceType == resource_type }
    end

    def get_params()
        { 
            qr_code: @qr_code, 
            bundle: @bundle, 
            params: @params 
        }
    end

    def has_error?()
        @error.present? || false
    end

    def get_error()
        @error
    end

    private
    def validation()
        raise NotImplementedError.new("You must implement #{self.class}##{__method__}")
    end
end