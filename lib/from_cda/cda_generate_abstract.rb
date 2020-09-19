require 'json'
require 'fhir_client'
require 'securerandom'

class CdaGenerateAbstract
    def initialize(params)        
        @document = params[:document]
        @bundle = params[:bundle]
    end

    def perform()
        raise NotImplementedError.new("You must implement #{self.class}##{__method__}")
    end

    def get_clinical_document()
        result = @document.xpath('/EPD/Prescription/ClinicalDocument')
        unless result.present?
            result = @document.xpath('/ClinicalDocument')
        end
        result
    end

    def get_composition()
        get_resources_from_type('Composition').first
    end

    def get_resources_from_type(resource_type)
        @bundle.entry.select{ |c| c.resource.resourceType == resource_type }
    end

    def get_resources_from_identifier(resource_type, identifier)
        get_resources_from_type(resource_type).select{ |c| c.resource.identifier.include?(identifier) }
    end

    def generate_identifier(id)
        return unless id.present?
        identifier = FHIR::Identifier.new
        identifier.system = "urn:oid:#{id.xpath('@root').text}"
        identifier.value = id.xpath('@extension').text
        identifier
    end

    def generate_human_name(name)
        return unless name.present?
        human_name = FHIR::HumanName.new
        human_name.use = :official
        human_name.family = name.xpath('family').text
        human_name.given << name.xpath('given').text

        extension = FHIR::Extension.new
        extension.url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-representation"
        extension.valueCode = name.xpath('@use').text
        human_name.extension << extension
        human_name
    end

    def generate_address(addr)
        return unless addr.present?
        address = FHIR::Address.new
        address.use =
            case addr.xpath('@use').text
            when 'HP' then :home # 自宅
            when 'WP' then :work # 勤務先
            when 'TMP' then :temp # 一時的な住所
            end
        address.country = addr.xpath('county').text
        address.state = addr.xpath('state').text
        address.city = addr.xpath('city').text
        address.line << addr.xpath('streetAddressLine').text
        address.postalCode = addr.xpath('postalCode').text
        address
    end

    def generate_contact_point(telecom)
        return unless telecom.present?
        contact_point = FHIR::ContactPoint.new
        contact_point.use = 
            case telecom.xpath('@use').text
            when 'HP' then :home
            when 'WP' then :work
            when 'MC' then :mobile
            end            
        if telecom.xpath('@value').text.match(/^(?=.*:).*$/).present?
            contact_point.system = 
                case telecom.xpath('@value').text.match(/(.*)(?=:)/).to_s
                when 'tel' then :phone
                when 'fax' then :fax
                end
            contact_point.value = telecom.xpath('@value').text.match(/(?<=:)(.*)/).to_s
        else
            contact_point.value = telecom.xpath('@value').text
        end
        contact_point
    end

    def generate_quantity(x_quantity)
        return unless x_quantity.present?
        quantity = FHIR::Quantity.new
        quantity.value = x_quantity.xpath('@value').text.to_f
        quantity.unit = x_quantity.xpath('@unit').text
        quantity
    end

    def generate_codeable_concept(code)
        return unless code.present?
        create_codeable_concept(code.xpath('@code').text, code.xpath('@displayName').text, "urn:oid:#{code.xpath('@codeSystem').text}")
    end

    def create_identifier(value, system)
        identifier = FHIR::Identifier.new
        identifier.system = system
        identifier.value = value
        identifier
    end

    def create_codeable_concept(code, display, system = 'LC')
        codeable_concept = FHIR::CodeableConcept.new
        coding = FHIR::Coding.new
        coding.code = code
        coding.display = display
        coding.system = system
        codeable_concept.coding << coding
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