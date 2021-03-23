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

  def get_resource_from_id(id)
    @bundle.entry.find{|e|e.resource.id == id}&.resource
  end

  def get_resources_from_type(resource_type)
    @bundle.entry.select{|e|e.resource.resourceType == resource_type}.map{|e|e.resource}
  end

  def get_resources_from_identifier(resource_type, identifier)
    get_resources_from_type(resource_type).select{|r|r.identifier.include?(identifier)}
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
    human_name.text = "#{name.xpath('family').text}#{name.xpath('given').text}"

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
    address.text = "#{address.state}#{address.city}#{address.line.join}"
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

  def generate_quantity(x_quantity, system = nil)
    return unless x_quantity.present?
    quantity = FHIR::Quantity.new
    quantity.value = x_quantity.xpath('@value').text.to_numeric
    quantity.unit = x_quantity.xpath('@unit').text
    quantity.system = system
    quantity
  end

  def generate_codeable_concept(code)
    return unless code.present?
    create_codeable_concept(code.xpath('@code').text, code.xpath('@displayName').text, "urn:oid:#{code.xpath('@codeSystem').text}")
  end

  def convert_oid_to_url(oid)
    case oid
    when 'urn:oid:1.2.392.100495.20.3.21' then create_url(:structure_definition, 'PrefectureNo') # 都道府県番号
    when 'urn:oid:1.2.392.100495.20.3.22' then create_url(:structure_definition, 'OrganizationCategory') # 点数表コード
    when 'urn:oid:1.2.392.100495.20.3.23' then create_url(:structure_definition, 'OrganizationNo') # 保険医療機関番号
    end
  end
end