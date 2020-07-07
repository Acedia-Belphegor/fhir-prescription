require 'nokogiri'
require './lib/hl7fhir/fhir_dispensing_generator'

class Api::Hl7::FhirDispensingGeneratorsController < ApplicationController
    # POST：リクエストBODYに設定されたHL7CDAをFHIR(json/xml)形式に変換して返す
    def create        
        document = Nokogiri::XML.parse(request.body.read)
        document.remove_namespaces!
        generator = FhirDispensingGenerator.new(document).perform
        respond_to do |format|
            format.json { render :json => generator.get_resources.to_json }
            format.xml  { render :xml => generator.get_resources.to_xml }
        end
    end
end