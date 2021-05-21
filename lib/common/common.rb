def build_identifier(value, system)
  identifier = FHIR::Identifier.new
  identifier.value = value
  identifier.system = system if value.present?
  identifier
end

def build_coding(code, display, system = 'LC')
  coding = FHIR::Coding.new
  coding.code = code
  coding.display = display
  coding.system = system
  coding
end

def build_codeable_concept(code, display, system = 'LC', text = nil)
  codeable_concept = FHIR::CodeableConcept.new
  codeable_concept.coding << build_coding(code, display, system) if code.present?
  codeable_concept.text = text || (code.blank? ? display : nil)
  codeable_concept
end

def build_codeable_concept_without_coding(text)
  codeable_concept = FHIR::CodeableConcept.new
  codeable_concept.text = text
  codeable_concept
end

def build_reference(resource, type = :uuid)
  reference = FHIR::Reference.new
  if type == :literal
    reference.reference = "#{resource.resourceType}/#{resource.id}"
  else
    reference.reference = "urn:uuid:#{resource.id}"
    reference.type = resource.resourceType
  end
  reference
end

def build_quantity(value, unit = nil, system = nil, code = nil)
  quantity = FHIR::Quantity.new
  quantity.value = case true
    when value.instance_of?(String)
      value.to_numeric
    when value.instance_of?(Float)
      value.integer? ? value.to_i : value
    else
      value
    end
  quantity.unit = unit
  quantity.system = code.present? ? system : nil # codeが未設定の場合はsystemも設定しない
  quantity.code = code
  quantity
end

def build_url(type, str)
  case type
  when :code_system
    "http://hl7.jp/fhir/ePrescription/CodeSystem/#{str}"
  when :structure_definition
    "http://hl7.jp/fhir/ePrescription/StructureDefinition/#{str}"
  when :value_set
    "http://hl7.jp/fhir/ePrescription/ValueSet/#{str}"
  else
    "http://hl7.jp/fhir/ePrescription/#{str}"
  end
end

def build_entry(resource)
  entry = FHIR::Bundle::Entry.new
  entry.resource = resource
  entry.fullUrl = "urn:uuid:#{resource.id}"
  entry
end