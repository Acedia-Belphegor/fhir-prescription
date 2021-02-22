require 'json'
require 'fhir_client'
require 'securerandom'

class QrGenerateAbstract
    def initialize(params)        
        @qr_code = params[:qr_code]
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
        @qr_code
    end

    def get_records(record_number)
        @qr_code.select{|record|record[:record_number].to_i == record_number}
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

    def create_reference(resource, type = :uuid)
        reference = FHIR::Reference.new
        if type == :literal
            reference.reference = "#{resource.resourceType}/#{resource.id}"
        else
            reference.reference = "urn:uuid:#{resource.id}"
            reference.type = resource.resourceType
        end
        reference
    end

    def create_quantity(value, unit = nil, system = nil)
        quantity = FHIR::Quantity.new
        quantity.value = value
        quantity.unit = unit
        quantity.system = system
        quantity
    end

    def create_url(type, str)
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

    def create_entry(resource)
        entry = FHIR::Bundle::Entry.new
        entry.resource = resource
        entry.fullUrl = "urn:uuid:#{resource.id}"
        entry
    end

    def get_receipt_medication_master()
        @master ||= load_receipt_medication_master
    end

    # 医薬品マスター読込
    # 仕様書: https://www.ssk.or.jp/seikyushiharai/tensuhyo/kihonmasta/kihonmasta_04.html
    def load_receipt_medication_master()
        CSV.table(
            Rails.root.join('fixtures').join('y_ALL20200918.csv'), 
            encoding: 'shift_jis', 
            converters: nil, 
            skip_blanks: true,
            headers: [
                "modified_class", # 変更区分
                "master_kind", # マスター種別
                "medication_code", # 医薬品コード
                "medication_name_length", # 医薬品名漢字有効桁数
                "medication_name", # 医薬品名漢字名称
                "medication_kananame_length", # 医薬品名カナ有効桁数
                "medication_kananame", # 医薬品名カナ名称
                "unit_code", # 単位コード
                "unit_name_length", # 単位漢字有効桁数
                "unit_name", # 単位漢字名称
                "amount_kind", # 新又は現金額/金額種別
                "amount", # 新又は現金額
                "reserve1", # 予備
                "drug", # 麻薬・毒薬・覚醒剤原料・向精神薬
                "neurolysis", # 神経破壊剤
                "biologics", # 生物学的製剤
                "generic", # 後発品
                "reserve2", # 予備
                "dental_specific_drug", # 歯科特定薬剤
                "contrast_medium", # 造影（補助）剤
                "injection_capacity", # 注射容量
                "listing_method_identification", # 収載方式等識別
                "related_product_names_etc", # 商品名等関連
                "old_amount_kind", # 旧金額/金額種別
                "old_amount", # 旧金額
                "kanjiname_modified_class", # 漢字名称変更区分
                "kananame_modified_class", # カナ名称変更区分
                "dosage_form", # 剤形
                "reserve3", # 予備
                "modified_date", # 変更年月日
                "abolished_date", # 廃止年月日
                "nhi_price_standard_code", # 薬価基準収載医薬品コード
                "publication_sequence_number", # 公表順序番号
                "expiration_date", # 経過措置年月日又は商品名医薬品コード使用期限
                "basic_kanji_name", # 基本漢字名称
            ]
        )
    end
end