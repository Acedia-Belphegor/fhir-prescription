require 'json'
require 'nokogiri'
require 'fhir_client'

Dir[File.expand_path(File.dirname(__FILE__)) << '/cda_generate_*.rb'].each do |file|
    require file
end

class CdaFhirAbstractGenerator    
    def initialize(params)
        @params = params
        document = Nokogiri::XML.parse(Base64.decode64(params[:document]).force_encoding("utf-8"))
        document.remove_namespaces!
        @document = document
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
            document: @document, 
            bundle: @bundle,
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