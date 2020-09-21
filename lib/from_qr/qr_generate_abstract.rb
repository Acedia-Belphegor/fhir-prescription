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