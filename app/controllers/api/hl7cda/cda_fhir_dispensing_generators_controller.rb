require 'nokogiri'
require './lib/from_cda/cda_fhir_dispensing_generator'

class Api::Hl7cda::CdaFhirDispensingGeneratorsController < ApplicationController
    # POST：リクエストBODYに設定されたHL7CDAをFHIR(json/xml)形式に変換して返す
    def create        
        document = Nokogiri::XML.parse(request.body.read)
        document.remove_namespaces!
        generator = CdaFhirDispensingGenerator.new(document).perform
        respond_to do |format|
            format.json { render :json => generator.get_resources.to_json }
            format.xml  { render :xml => generator.get_resources.to_xml }
        end
    end
end