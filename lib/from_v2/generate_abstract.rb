require 'json'
require 'fhir_client'
require 'securerandom'

class GenerateAbstract
    def initialize(params)        
        @message = params[:message]
        @bundle = params[:bundle]
    end

    def perform()
        raise NotImplementedError.new("You must implement #{self.class}##{__method__}")
    end

    def get_message()
        @message
    end

    def get_segments(id)
        @message.select{|segment|segment[:segment_id] == id}
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

    def generate_identifier(value, system)
        identifier = FHIR::Identifier.new
        identifier.system = system
        identifier.value = value
        identifier
    end

    # HL7v2:XPN,XCN -> FHIR:HumanName
    def generate_human_name(name)
        return unless name.present?
        human_name = FHIR::HumanName.new
        human_name.use = :official
        human_name.family = name[:family_name][:surname]
        human_name.given << name[:given_name]

        extension = FHIR::Extension.new
        extension.url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-representation"
        extension.valueCode = case name[:name_representation_code]
                              when 'I' then :IDE # 漢字
                              when 'P' then :SYL # カナ
                              end
        human_name.extension << extension
        human_name
    end

    # HL7v2:XAD -> FHIR:Address 変換
    def generate_address(addr)
        return unless addr.present?
        address = FHIR::Address.new
        address.use = case addr[:address_type]
                      when 'H' then :home # 自宅
                      when 'B' then :work # 勤務先
                      when 'C' then :temp # 一時的な住所
                      end
        address.country = addr[:country]
        address.state = addr[:state_or_province]
        address.city = addr[:city]
        address.line << addr[:street_address]
        address.line << addr[:other_geographic_designation]
        address.postalCode = addr[:zip_or_postal_code]
        address
    end

    # HL7v2:XTN -> FHIR:ContactPoint 変換
    def generate_contact_point(telecom)
        return unless telecom.present?
        contact_point = FHIR::ContactPoint.new
        case telecom[:telecommunication_use_code]
        when 'PRN' # 主要な自宅番号
            contact_point.use = :home
        when 'WPN' # 勤務先番号
            contact_point.use = :work
        when 'NET' # ネットワーク(電子メール)アドレス
            contact_point.system = :email
        end
        case telecom[:telecommunication_equipment_type]
        when 'PH' # 電話
            contact_point.system = :phone
        when 'FX' # ファックス
            contact_point.system = :fax
        when 'CP' # 携帯電話
            contact_point.system = :phone
            contact_point.use = :mobile
        end
        contact_point.value = telecom[:unformatted_telephone_number_]
        contact_point
    end

    # HL7v2:CQ -> FHIR:Quantity 変換
    def generate_quantity(cq)
        return unless cq.present?
        quantity = FHIR::Quantity.new
        quantity.value = cq[:quantity].to_f
        if cq[:units].present?
            quantity.unit = cq[:units][:text]
            quantity.code = cq[:units][:code]
        end
        quantity
    end

    def generate_codeable_concept(code)
        return unless code.present?
        codeable_concept = FHIR::CodeableConcept.new        
        if code[:identifier].present?
            coding = FHIR::Coding.new
            coding.code = code[:identifier]
            coding.display = code[:text]
            coding.system = code[:name_of_coding_system]
            codeable_concept.coding << coding
        end
        if code[:alternate_identifier].present?
            coding = FHIR::Coding.new
            coding.code = code[:alternate_identifier]
            coding.display = code[:alternate_text]
            coding.system = code[:name_of_alternate_coding_system]
            codeable_concept.coding << coding
        end
        codeable_concept
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
        reference.type = resource.resourceType
        reference.id = resource.id
        reference
    end

    def create_quantity(value, unit = nil)
        quantity = FHIR::Quantity.new
        quantity.value = value
        quantity.unit = unit
        quantity
    end
end