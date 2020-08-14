require 'json'
require "base64"
require 'fhir_client'
require_relative 'v2_message_parser'

Dir[File.expand_path(File.dirname(__FILE__)) << '/v2_generate_*.rb'].each do |file|
    require file
end

class V2FhirAbstractGenerator    
    def initialize(params)
        @params = params
        str = if Encoding.find(params[:encoding]) == Encoding::ISO_2022_JP
            Base64.decode64(params[:message]).force_encoding(Encoding::ISO_2022_JP).encode("utf-8")
        else
            Base64.decode64(params[:message]).force_encoding("utf-8")
        end
        @message = V2MessageParser.new(str).to_simplify
        validation
        @client = FHIR::Client.new("http://localhost:8080", default_format: 'json')
        @client.use_r4
        FHIR::Model.client = @client            
        @bundle = FHIR::Bundle.new
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
            message: @message, 
            bundle: @bundle, 
            params: @params 
        }
    end

    private
    def validation()
        raise NotImplementedError.new("You must implement #{self.class}##{__method__}")
    end

    # def validate_message_type(message_code, trigger_event)
    #     message_types = @parser.get_parsed_fields('MSH','Message Type')
    #     return false if message_types.blank?

    #     message_types.first['array_data'].first.select{ |c| ["Message Code","Trigger Event"].include?(c['name']) }.each do |element|
    #         case element['name']
    #         when 'Message Code'
    #             return false unless element['value'] == message_code
    #         when 'Trigger Event'
    #             return false unless element['value'] == trigger_event
    #         end
    #     end
    #     true
    # end
end