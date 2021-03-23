require 'json'
require 'nokogiri'
require 'fhir_client'

Dir[File.expand_path('..', File.dirname(__FILE__)) << '/common/*.rb'].each do |file| 
    require file
end

Dir[File.expand_path(File.dirname(__FILE__)) << '/cda_generate_*.rb'].each do |file|
    require file
end

class CdaFhirAbstractGenerator    
  def initialize(params)
    Time.zone = 'Tokyo'
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
    @bundle.timestamp = Time.current
    meta = FHIR::Meta.new
    meta.profile << "http://hl7.jp/fhir/ePrescription/StructureDefinition/ePrescription-Bundle/1.0"
    @bundle.meta = meta
  end

  def perform()
    raise NotImplementedError.new("You must implement #{self.class}##{__method__}")
  end

  def to_json()
    @bundle.to_json
  end

  def to_xml()
    @bundle.to_xml
  end

  def get_resource_from_id(id)
    @bundle.entry.find{|e|e.resource.id == id}&.resource
  end

  def get_resources_from_type(resource_type)
    @bundle.entry.select{|e|e.resource.resourceType == resource_type}.map{|e|e.resource}
  end

  def get_params()
    { 
      document: @document, # CDAドキュメント（変換元）
      bundle: @bundle, # FHIR Bundleリソース（変換先）
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