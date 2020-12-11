require 'json'
require 'fhir_client'
require 'securerandom'

class SipsGenerateAbstract

    PATIENT = "1".freeze # 患者情報部
    PRESCRIPTION = "2".freeze # 処方箋情報部
    DOSAGE = "3".freeze # 用法部
    MEDICATION = "4".freeze # 薬品部
    DISPENSE = "5".freeze # 調剤録部
    DISPENSE_DETAIL = "6".freeze # 調剤録明細部
    ADDITIONAL_CHARGE = "7".freeze # 加算情報部

    def initialize(params)        
        @nsips = params[:nsips]
        @bundle = params[:bundle]
        @params = params[:params]
    end

    def perform()
        raise NotImplementedError.new("You must implement #{self.class}##{__method__}")
    end

    def get_params()
        @params
    end

    def get_all_records()
        @nsips
    end

    def get_records(identifier)
        @nsips.select{|record|record[:identifier] == identifier}
    end

    def get_composition()
        get_resources_from_type('Composition').first
    end

    def get_resource_from_id(id)
        @bundle.entry.find{|e|e.resource.id == id}&.resource
    end

    def get_resources_from_type(resource_type)
        @bundle.entry.select{|e|e.resource.resourceType == resource_type}.map{|e|e.resource}
    end

    def get_resources_from_identifier(resource_type, identifier)
        get_resources_from_type(resource_type).select{|r|r.identifier.include?(identifier)}
    end

    def create_identifier(value, system)
        identifier = FHIR::Identifier.new
        identifier.system = system
        identifier.value = value
        identifier
    end

    def create_coding(code, display, system = 'LC')
        coding = FHIR::Coding.new
        coding.code = code
        coding.display = display
        coding.system = system
        coding
    end

    def create_codeable_concept(code, display, system = 'LC')
        codeable_concept = FHIR::CodeableConcept.new
        codeable_concept.coding << create_coding(code, display, system)
        codeable_concept
    end

    def create_reference(resource)
        reference = FHIR::Reference.new
        reference.reference = "#{resource.resourceType}/#{resource.id}"
        reference
    end

    def create_quantity(value, unit = nil)
        quantity = FHIR::Quantity.new
        quantity.value = value
        quantity.unit = unit
        quantity
    end
end