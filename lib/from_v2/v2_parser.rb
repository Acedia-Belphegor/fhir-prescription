require 'json'
require 'pathname'

class V2Parser

    SEGMENT_DELIM = "\r".freeze # セグメントターミネータ
    FIELD_DELIM = '|'.freeze # フィールドセパレータ
    ELEMENT_DELIM = '^'.freeze # 成分セパレータ
    REPEAT_DELIM = '~'.freeze # 反復セパレータ
    
    def initialize(raw_message = nil)
        # データ型を定義したJSONファイルを読み込む        
        @hl7_datatypes = File.open(Pathname.new(File.dirname(File.expand_path(__FILE__))).join('json').join('HL7_DATATYPE.json')) do |io|
            JSON.load(io)
        end
        # セグメントを定義したJSONファイルを読み込む        
        @hl7_segments = open(Pathname.new(File.dirname(File.expand_path(__FILE__))).join('json').join('HL7_SEGMENT.json')) do |io|
            JSON.load(io)
        end
        # 引数にRawデータが設定されている場合はパースする
        parse(raw_message) if raw_message.present?
    end

    def to_simplify
        @parsed_message.map{|segment|
            Hash[segment.map{|field|
                [
                    replacement_characters(field[:name]).to_sym, 
                    field[:array_data].present? ? field[:array_data].map{|repeat_field|Hash[repeat_field.map{|element|[replacement_characters(element[:name]).to_sym, element_to_simplify(element)]}]} : field[:value]
                ]
            }]
        }
    end

    # HL7メッセージをJSON形式にパースする
    def parse(raw_message)
        # 改行コード(セグメントターミネータ)が「\n」の場合は「\r」に置換する
        raw_message.gsub!("\n", SEGMENT_DELIM)
        # セグメント分割
        segments = raw_message.split(SEGMENT_DELIM)
        results = []
    
        segments.each do |segment|
            # メッセージ終端の場合は処理を抜ける
            break if /\x1c/.match(segment)
            # フィールド分割
            fields = segment.split(FIELD_DELIM)
            segment_id = fields[0]
            segment_array = create_new_segment(segment_id)
            segment_idx = 0

            segment_array.each do |field|
                # MSH-1は強制的にフィールドセパレータをセットする
                if segment_id == 'MSH' && field[:name] == 'Field Separator'
                    value = FIELD_DELIM
                else
                    value = if fields.length > segment_idx
                        fields[segment_idx]
                    else
                        ''
                    end
                    segment_idx += 1
                end
                # 分割したフィールドの値をvalue要素として追加する
                field.store(:value, value)
                repeat_fields = []

                # MSH-2(コード化文字)には反復セパレータ(~)が含まれているので反復フィールド分割処理を行わない
                if segment_id == 'MSH' && field[:name] == 'Encoding Characters'
                    repeat_fields << value
                else
                    # 反復フィールド分割
                    repeat_fields = value.split(REPEAT_DELIM)
                end
                # フィールドデータを再帰的にパースする
                field.store(:array_data, repeat_fields.map{|repeat_field| element_parse(repeat_field, field[:type], ELEMENT_DELIM)}.compact)
            end                
            results << segment_array
        end
        @parsed_message = results
    end

    private
    def element_parse(raw_data, type_id, delim)
        element_array = create_new_datatype(type_id)
        unless element_array.instance_of?(Array)
            return
        end
        elements = raw_data.split(delim)

        element_array.each_with_index do |element, idx|
            value = if elements.length > idx
                elements[idx]
            else
                ''
            end
            element.store(:value, value)                
            element.store(:array_data, element_parse(value, element[:type], '&')) if value.present?
        end
        element_array
    end

    def element_to_simplify(element)
        if element[:array_data].present?
            Hash[element[:array_data].map{|element|[replacement_characters(element[:name]).to_sym, element_to_simplify(element)]}]
        else
            element[:value]
        end
    end

    def replacement_characters(str)
        str = str.downcase
        str = str.gsub(' - ', '_')
        str = str.gsub(/[[:space:]|-]/, '_')
        str = str.gsub(/[^0-9a-zA-Z_]/, '')
    end

    # 空のセグメントオブジェクトを生成する
    def create_new_segment(id)
        Marshal.load(Marshal.dump(@hl7_segments[id])).map{|c|c.map{|k,v|[k.to_sym, v]}.to_h}
    end

    # 空のデータ型オブジェクトを生成する
    def create_new_datatype(id)
        result = Marshal.load(Marshal.dump(@hl7_datatypes[id]))
        if result.instance_of?(Array)
            result = result.map{|c|c.map{|k,v|[k.to_sym, v]}.to_h}
        end
        result
    end
end
__END__
[
    {
      "segment_id": "MSH",
      "field_separator": "|",
      "encoding_characters": "^~&",
      "sending_application": [
        {
          "namespace_id": "HL7v2",
          "universal_id": "",
          "universal_id_type": ""
        }
      ],
      "sending_facility": [
        {
          "namespace_id": "1319999999",
          "universal_id": "",
          "universal_id_type": ""
        }
      ],
      "receiving_application": [
        {
          "namespace_id": "HL7FHIR",
          "universal_id": "",
          "universal_id_type": ""
        }
      ],
      "receiving_facility": [
        {
          "namespace_id": "1319999999",
          "universal_id": "",
          "universal_id_type": ""
        }
      ],
      "datetime_of_message": [
        {
          "time": "20160821161523",
          "degree_of_precision": ""
        }
      ],
      "security": "",
      "message_type": [
        {
          "message_code": "RDE",
          "trigger_event": "O11",
          "message_structure": "RDE_O11"
        }
      ],
      "message_control_id": "201608211615230143",
      "processing_id": [
        {
          "processing_id": "P",
          "processing_mode": ""
        }
      ],
      "version_id": [
        {
          "version_id": "2.5",
          "internationalization_code": "",
          "international_version_id": ""
        }
      ],
      "sequence_number": "",
      "continuation_pointer": "",
      "accept_acknowledgment_type": "",
      "application_acknowledgment_type": "",
      "country_code": "",
      "character_set": "~ISOIR87",
      "principal_language_of_message": "",
      "alternate_character_set_handling_scheme": "ISO 2022-1994",
      "message_profile_identifier": ""
    },
    {
      "segment_id": "PID",
      "set_id_pid": "",
      "patient_id": "",
      "patient_identifier_list": [
        {
          "id_number": "1000000001",
          "check_digit": "",
          "check_digit_scheme_": "",
          "assigning_authority": "",
          "identifier_type_code": "PI",
          "assigning_facility": "",
          "effective_date": "",
          "expiration_date": "",
          "assigning_jurisdiction": "",
          "assigning_agency_or_department": ""
        }
      ],
      "alternate_patient_id_pid": "",
      "patient_name": [
        {
          "family_name": {
            "surname": "患者",
            "own_surname_prefix": "",
            "own_surname": "",
            "surname_prefix_from_partnerspouse": "",
            "surname_from_partnerspouse": ""
          },
          "given_name": "太郎",
          "second_and_further_given_names_or_initials_thereof": "",
          "suffix_eg_jr_or_iii": "",
          "prefix_eg_dr": "",
          "degree_eg_md": "",
          "name_type_code": "L",
          "name_representation_code": "I",
          "name_context": "",
          "name_validity_range": "",
          "name_assembly_order": "",
          "effective_date": "",
          "expiration_date": "",
          "professional_suffix": ""
        },
        {
          "family_name": {
            "surname": "カンジャ",
            "own_surname_prefix": "",
            "own_surname": "",
            "surname_prefix_from_partnerspouse": "",
            "surname_from_partnerspouse": ""
          },
          "given_name": "タロウ",
          "second_and_further_given_names_or_initials_thereof": "",
          "suffix_eg_jr_or_iii": "",
          "prefix_eg_dr": "",
          "degree_eg_md": "",
          "name_type_code": "L",
          "name_representation_code": "P",
          "name_context": "",
          "name_validity_range": "",
          "name_assembly_order": "",
          "effective_date": "",
          "expiration_date": "",
          "professional_suffix": ""
        }
      ],
      "mothers_maiden_name": "",
      "datetime_of_birth": [
        {
          "time": "19791101",
          "degree_of_precision": ""
        }
      ],
      "administrative_sex": "M",
      "patient_alias": "",
      "race": "",
      "patient_address": [
        {
          "street_address": "",
          "other_designation": "",
          "city": "渋谷区",
          "state_or_province": "東京都",
          "zip_or_postal_code": "1510071",
          "country": "JPN",
          "address_type": "H",
          "other_geographic_designation": "東京都渋谷区本町三丁目１２ー１",
          "countyparish_code": "",
          "census_tract": "",
          "address_representation_code": "",
          "address_validity_range": "",
          "effective_date": "",
          "expiration_date": ""
        }
      ],
      "county_code": "",
      "phone_number_home": [
        {
          "telephone_number": "",
          "telecommunication_use_code": "PRN",
          "telecommunication_equipment_type": "PH",
          "email_address": "",
          "country_code": "",
          "areacity_code": "",
          "local_number": "",
          "extension": "",
          "any_text": "",
          "extension_prefix": "",
          "speed_dial_code": "",
          "unformatted_telephone_number_": "03-1234-5678"
        }
      ],
      "phone_number_business": "",
      "primary_language": "",
      "marital_status": "",
      "religion": "",
      "patient_account_number": "",
      "ssn_number_patient": "",
      "drivers_license_number_patient": "",
      "mothers_identifier": "",
      "ethnic_group": "",
      "birth_place": "",
      "multiple_birth_indicator": "N",
      "birth_order": "",
      "citizenship": "",
      "veterans_military_status": "",
      "nationality_": "",
      "patient_death_date_and_time": "",
      "patient_death_indicator": "N",
      "identity_unknown_indicator": "",
      "identity_reliability_code": "",
      "last_update_datetime": [
        {
          "time": "20161028143309",
          "degree_of_precision": ""
        }
      ],
      "last_update_facility": "",
      "species_code": "",
      "breed_code": "",
      "strain": "",
      "production_class_code": "",
      "tribal_citizenship": ""
    },
    {
      "segment_id": "IN1",
      "set_id_in1": "1",
      "insurance_plan_id": [
        {
          "identifier": "06",
          "text": "組合管掌健康保険",
          "name_of_coding_system": "JHSD0001",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "insurance_company_id": [
        {
          "id_number": "06050116",
          "check_digit": "",
          "check_digit_scheme_": "",
          "assigning_authority": "",
          "identifier_type_code": "",
          "assigning_facility": "",
          "effective_date": "",
          "expiration_date": "",
          "assigning_jurisdiction": "",
          "assigning_agency_or_department": ""
        }
      ],
      "insurance_company_name": "",
      "insurance_company_address": "",
      "insurance_co_contact_person": "",
      "insurance_co_phone_number": "",
      "group_number": "",
      "group_name": "",
      "insureds_group_emp_id": [
        {
          "id_number": "９２０４５",
          "check_digit": "",
          "check_digit_scheme_": "",
          "assigning_authority": "",
          "identifier_type_code": "",
          "assigning_facility": "",
          "effective_date": "",
          "expiration_date": "",
          "assigning_jurisdiction": "",
          "assigning_agency_or_department": ""
        }
      ],
      "insureds_group_emp_name": [
        {
          "organization_name": "１０",
          "organization_name_type_code": "",
          "id_number": "",
          "check_digit": "",
          "check_digit_scheme_": "",
          "assigning_authority": "",
          "identifier_type_code": "",
          "assigning_facility": "",
          "name_representation_code": "",
          "organization_identifier": ""
        }
      ],
      "plan_effective_date": "19990514",
      "plan_expiration_date": "",
      "authorization_information": "",
      "plan_type": "",
      "name_of_insured": "",
      "insureds_relationship_to_patient": [
        {
          "identifier": "SEL",
          "text": "本人",
          "name_of_coding_system": "HL70063",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "insureds_date_of_birth": "",
      "insureds_address": "",
      "assignment_of_benefits": "",
      "coordination_of_benefits": "",
      "coord_of_ben_priority": "",
      "notice_of_admission_flag": "",
      "notice_of_admission_date": "",
      "report_of_eligibility_flag": "",
      "report_of_eligibility_date": "",
      "release_information_code": "",
      "pre_admit_cert_pac": "",
      "verification_datetime": "",
      "verification_by": "",
      "type_of_agreement_code": "",
      "billing_status": "",
      "lifetime_reserve_days": "",
      "delay_before_lr_day": "",
      "company_plan_code": "",
      "policy_number": "",
      "policy_deductible": "",
      "policy_limit_amount": "",
      "policy_limit_days": "",
      "room_rate_semi_private": "",
      "room_rate_private": "",
      "insureds_employment_status": "",
      "insureds_administrative_sex": "",
      "insureds_employers_address": "",
      "verification_status": "",
      "prior_insurance_plan_id": "",
      "coverage_type": "",
      "handicap_": "",
      "insureds_id_number": "",
      "signature_code": "",
      "signature_code_date": "",
      "insureds_birth_place": "",
      "vip_indicator": ""
    },
    {
      "segment_id": "ORC",
      "order_control": "NW",
      "placer_order_number": [
        {
          "entity_identifier": "12345678",
          "namespace_id": "",
          "universal_id": "",
          "universal_id_type": ""
        }
      ],
      "filler_order_number": "",
      "placer_group_number": [
        {
          "entity_identifier": "12345678_01",
          "namespace_id": "",
          "universal_id": "",
          "universal_id_type": ""
        }
      ],
      "order_status": "",
      "response_flag": "",
      "quantitytiming": "",
      "parent": "",
      "datetime_of_transaction": [
        {
          "time": "20160825",
          "degree_of_precision": ""
        }
      ],
      "entered_by": "",
      "verified_by": "",
      "ordering_provider": [
        {
          "id_number": "123456",
          "family_name": {
            "surname": "医師",
            "own_surname_prefix": "",
            "own_surname": "",
            "surname_prefix_from_partnerspouse": "",
            "surname_from_partnerspouse": ""
          },
          "given_name": "春子",
          "second_and_further_given_names_or_initials_thereof": "",
          "suffix_eg_jr_or_iii": "",
          "prefix_eg_dr": "",
          "degree_eg_md": "",
          "source_table": "",
          "assigning_authority": "",
          "name_type_code": "L",
          "identifier_check_digit": "",
          "check_digit_scheme": "",
          "identifier_type_code": "",
          "assigning_facility": "",
          "name_representation_code": "I",
          "name_context": "",
          "name_validity_range": "",
          "name_assembly_order": "",
          "effective_date": "",
          "expiration_date": "",
          "professional_suffix": "",
          "assigning_jurisdiction": "",
          "assigning_agency_or_department": ""
        },
        {
          "id_number": "",
          "family_name": {
            "surname": "イシ",
            "own_surname_prefix": "",
            "own_surname": "",
            "surname_prefix_from_partnerspouse": "",
            "surname_from_partnerspouse": ""
          },
          "given_name": "ハルコ",
          "second_and_further_given_names_or_initials_thereof": "",
          "suffix_eg_jr_or_iii": "",
          "prefix_eg_dr": "",
          "degree_eg_md": "",
          "source_table": "",
          "assigning_authority": "",
          "name_type_code": "L",
          "identifier_check_digit": "",
          "check_digit_scheme": "",
          "identifier_type_code": "",
          "assigning_facility": "",
          "name_representation_code": "P",
          "name_context": "",
          "name_validity_range": "",
          "name_assembly_order": "",
          "effective_date": "",
          "expiration_date": "",
          "professional_suffix": "",
          "assigning_jurisdiction": "",
          "assigning_agency_or_department": ""
        }
      ],
      "enterers_location": "",
      "call_back_phone_number": "",
      "order_effective_datetime": "",
      "order_control_code_reason": "",
      "entering_organization": [
        {
          "identifier": "01",
          "text": "内科",
          "name_of_coding_system": "99Z01",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "entering_device": "",
      "action_by": "",
      "advanced_beneficiary_notice_code": "",
      "ordering_facility_name": [
        {
          "organization_name": "メドレークリニック",
          "organization_name_type_code": "",
          "id_number": "",
          "check_digit": "",
          "check_digit_scheme_": "",
          "assigning_authority": "",
          "identifier_type_code": "",
          "assigning_facility": "",
          "name_representation_code": "",
          "organization_identifier": ""
        }
      ],
      "ordering_facility_address": [
        {
          "street_address": "",
          "other_designation": "",
          "city": "港区",
          "state_or_province": "東京都",
          "zip_or_postal_code": "",
          "country": "JPN",
          "address_type": "",
          "other_geographic_designation": "東京都港区六本木３−２−１",
          "countyparish_code": "",
          "census_tract": "",
          "address_representation_code": "",
          "address_validity_range": "",
          "effective_date": "",
          "expiration_date": ""
        }
      ],
      "ordering_facility_phone_number": "",
      "ordering_provider_address": "",
      "order_status_modifier": "",
      "advanced_beneficiary_notice_override_reason": "",
      "fillers_expected_availability_datetime": "",
      "confidentiality_code": "",
      "order_type": [
        {
          "identifier": "O",
          "text": "外来患者オーダ",
          "name_of_coding_system": "HL70482",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "enterer_authorization_mode": ""
    },
    {
      "segment_id": "RXE",
      "quantitytiming": "",
      "give_code": [
        {
          "identifier": "103835401",
          "text": "ムコダイン錠２５０ｍｇ",
          "name_of_coding_system": "HOT",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "give_amount_minimum": "1",
      "give_amount_maximum": "",
      "give_units": [
        {
          "identifier": "TAB",
          "text": "錠",
          "name_of_coding_system": "MR9P",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "give_dosage_form": [
        {
          "identifier": "TAB",
          "text": "錠",
          "name_of_coding_system": "MR9P",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "providers_administration_instructions": [
        {
          "identifier": "01",
          "text": "１回目から服用",
          "name_of_coding_system": "JHSP0005",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "deliver_to_location": "",
      "substitution_status": "",
      "dispense_amount": "9",
      "dispense_units": [
        {
          "identifier": "TAB",
          "text": "錠",
          "name_of_coding_system": "MR9P",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "number_of_refills": "",
      "ordering_providers_dea_number": "",
      "pharmacisttreatment_suppliers_verifier_id": "",
      "prescription_number": "",
      "number_of_refills_remaining": "",
      "number_of_refillsdoses_dispensed": "",
      "dt_of_most_recent_refill_or_dose_dispensed": "",
      "total_daily_dose": [
        {
          "quantity": "3",
          "units": {
            "identifier": "TAB",
            "text": "錠",
            "name_of_coding_system": "MR9P",
            "alternate_identifier": "",
            "alternate_text": "",
            "name_of_alternate_coding_system": "",
            "coding_system_version_id": "",
            "alternate_coding_system_version_id": "",
            "original_text": ""
          }
        }
      ],
      "needs_human_review": "",
      "pharmacytreatment_suppliers_special_dispensing_instructions": [
        {
          "identifier": "OHP",
          "text": "外来処方",
          "name_of_coding_system": "MR9P",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        },
        {
          "identifier": "OHI",
          "text": "院内処方",
          "name_of_coding_system": "MR9P",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "give_per_time_unit": "",
      "give_rate_amount": "",
      "give_rate_units": "",
      "give_strength": "",
      "give_strength_units": "",
      "give_indication": [
        {
          "identifier": "21",
          "text": "内服",
          "name_of_coding_system": "JHSP0003",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "dispense_package_size": "",
      "dispense_package_size_unit": "",
      "dispense_package_method": "",
      "supplementary_code": "",
      "original_order_datetime": "",
      "give_drug_strength_volume": "",
      "give_drug_strength_volume_units": "",
      "controlled_substance_schedule": "",
      "formulary_status": "",
      "pharmaceutical_substance_alternative": "",
      "pharmacy_of_most_recent_fill": "",
      "initial_dispense_amount": "",
      "dispensing_pharmacy": "",
      "dispensing_pharmacy_address": "",
      "deliver_to_patient_location": "",
      "deliver_to_address": "",
      "pharmacy_order_type": ""
    },
    {
      "segment_id": "TQ1",
      "set_id_tq1": "",
      "quantity": "",
      "repeat_pattern": [
        {
          "repeat_pattern_code": {
            "identifier": "1013044400000000",
            "text": "内服・経口・１日３回朝昼夕食後",
            "name_of_coding_system": "JAMISDP01",
            "alternate_identifier": "",
            "alternate_text": "",
            "name_of_alternate_coding_system": "",
            "coding_system_version_id": "",
            "alternate_coding_system_version_id": "",
            "original_text": ""
          },
          "calendar_alignment": "",
          "phase_range_begin_value": "",
          "phase_range_end_value": "",
          "period_quantity": "",
          "period_units": "",
          "institution_specified_time": "",
          "event": "",
          "event_offset_quantity": "",
          "event_offset_units": "",
          "general_timing_specification": ""
        }
      ],
      "explicit_time": "",
      "relative_time_and_units": "",
      "service_duration": [
        {
          "quantity": "3",
          "units": {
            "identifier": "D",
            "text": "日",
            "name_of_coding_system": "ISO+",
            "alternate_identifier": "",
            "alternate_text": "",
            "name_of_alternate_coding_system": "",
            "coding_system_version_id": "",
            "alternate_coding_system_version_id": "",
            "original_text": ""
          }
        }
      ],
      "start_datetime": [
        {
          "time": "20160825",
          "degree_of_precision": ""
        }
      ],
      "end_datetime": "",
      "priority": "",
      "condition_text": "",
      "text_instruction": "",
      "conjunction": "",
      "occurrence_duration": "",
      "total_occurrences": ""
    },
    {
      "segment_id": "RXR",
      "route": [
        {
          "identifier": "PO",
          "text": "口",
          "name_of_coding_system": "HL70162",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "administration_site": "",
      "administration_device": "",
      "administration_method": "",
      "routing_instruction": "",
      "administration_site_modifier": ""
    },
    {
      "segment_id": "ORC",
      "order_control": "NW",
      "placer_order_number": [
        {
          "entity_identifier": "12345678",
          "namespace_id": "",
          "universal_id": "",
          "universal_id_type": ""
        }
      ],
      "filler_order_number": "",
      "placer_group_number": [
        {
          "entity_identifier": "12345678_01",
          "namespace_id": "",
          "universal_id": "",
          "universal_id_type": ""
        }
      ],
      "order_status": "",
      "response_flag": "",
      "quantitytiming": "",
      "parent": "",
      "datetime_of_transaction": [
        {
          "time": "20160825",
          "degree_of_precision": ""
        }
      ],
      "entered_by": "",
      "verified_by": "",
      "ordering_provider": [
        {
          "id_number": "123456",
          "family_name": {
            "surname": "医師",
            "own_surname_prefix": "",
            "own_surname": "",
            "surname_prefix_from_partnerspouse": "",
            "surname_from_partnerspouse": ""
          },
          "given_name": "春子",
          "second_and_further_given_names_or_initials_thereof": "",
          "suffix_eg_jr_or_iii": "",
          "prefix_eg_dr": "",
          "degree_eg_md": "",
          "source_table": "",
          "assigning_authority": "",
          "name_type_code": "L",
          "identifier_check_digit": "",
          "check_digit_scheme": "",
          "identifier_type_code": "",
          "assigning_facility": "",
          "name_representation_code": "I",
          "name_context": "",
          "name_validity_range": "",
          "name_assembly_order": "",
          "effective_date": "",
          "expiration_date": "",
          "professional_suffix": "",
          "assigning_jurisdiction": "",
          "assigning_agency_or_department": ""
        },
        {
          "id_number": "",
          "family_name": {
            "surname": "イシ",
            "own_surname_prefix": "",
            "own_surname": "",
            "surname_prefix_from_partnerspouse": "",
            "surname_from_partnerspouse": ""
          },
          "given_name": "ハルコ",
          "second_and_further_given_names_or_initials_thereof": "",
          "suffix_eg_jr_or_iii": "",
          "prefix_eg_dr": "",
          "degree_eg_md": "",
          "source_table": "",
          "assigning_authority": "",
          "name_type_code": "L",
          "identifier_check_digit": "",
          "check_digit_scheme": "",
          "identifier_type_code": "",
          "assigning_facility": "",
          "name_representation_code": "P",
          "name_context": "",
          "name_validity_range": "",
          "name_assembly_order": "",
          "effective_date": "",
          "expiration_date": "",
          "professional_suffix": "",
          "assigning_jurisdiction": "",
          "assigning_agency_or_department": ""
        }
      ],
      "enterers_location": "",
      "call_back_phone_number": "",
      "order_effective_datetime": "",
      "order_control_code_reason": "",
      "entering_organization": [
        {
          "identifier": "01",
          "text": "内科",
          "name_of_coding_system": "99Z01",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "entering_device": "",
      "action_by": "",
      "advanced_beneficiary_notice_code": "",
      "ordering_facility_name": [
        {
          "organization_name": "メドレークリニック",
          "organization_name_type_code": "",
          "id_number": "",
          "check_digit": "",
          "check_digit_scheme_": "",
          "assigning_authority": "",
          "identifier_type_code": "",
          "assigning_facility": "",
          "name_representation_code": "",
          "organization_identifier": ""
        }
      ],
      "ordering_facility_address": [
        {
          "street_address": "",
          "other_designation": "",
          "city": "港区",
          "state_or_province": "東京都",
          "zip_or_postal_code": "",
          "country": "JPN",
          "address_type": "",
          "other_geographic_designation": "東京都港区六本木３−２−１",
          "countyparish_code": "",
          "census_tract": "",
          "address_representation_code": "",
          "address_validity_range": "",
          "effective_date": "",
          "expiration_date": ""
        }
      ],
      "ordering_facility_phone_number": "",
      "ordering_provider_address": "",
      "order_status_modifier": "",
      "advanced_beneficiary_notice_override_reason": "",
      "fillers_expected_availability_datetime": "",
      "confidentiality_code": "",
      "order_type": [
        {
          "identifier": "O",
          "text": "外来患者オーダ",
          "name_of_coding_system": "HL70482",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "enterer_authorization_mode": ""
    },
    {
      "segment_id": "RXE",
      "quantitytiming": "",
      "give_code": [
        {
          "identifier": "110626901",
          "text": "パンスポリンＴ錠１００ １００ｍｇ",
          "name_of_coding_system": "HOT",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "give_amount_minimum": "2",
      "give_amount_maximum": "",
      "give_units": [
        {
          "identifier": "TAB",
          "text": "錠",
          "name_of_coding_system": "MR9P",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "give_dosage_form": [
        {
          "identifier": "TAB",
          "text": "錠",
          "name_of_coding_system": "MR9P",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "providers_administration_instructions": [
        {
          "identifier": "01",
          "text": "１回目から服用",
          "name_of_coding_system": "JHSP0005",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "deliver_to_location": "",
      "substitution_status": "",
      "dispense_amount": "18",
      "dispense_units": [
        {
          "identifier": "TAB",
          "text": "錠",
          "name_of_coding_system": "MR9P",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "number_of_refills": "",
      "ordering_providers_dea_number": "",
      "pharmacisttreatment_suppliers_verifier_id": "",
      "prescription_number": "",
      "number_of_refills_remaining": "",
      "number_of_refillsdoses_dispensed": "",
      "dt_of_most_recent_refill_or_dose_dispensed": "",
      "total_daily_dose": [
        {
          "quantity": "6",
          "units": {
            "identifier": "TAB",
            "text": "錠",
            "name_of_coding_system": "MR9P",
            "alternate_identifier": "",
            "alternate_text": "",
            "name_of_alternate_coding_system": "",
            "coding_system_version_id": "",
            "alternate_coding_system_version_id": "",
            "original_text": ""
          }
        }
      ],
      "needs_human_review": "",
      "pharmacytreatment_suppliers_special_dispensing_instructions": [
        {
          "identifier": "OHP",
          "text": "外来処方",
          "name_of_coding_system": "MR9P",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        },
        {
          "identifier": "OHI",
          "text": "院内処方",
          "name_of_coding_system": "MR9P",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "give_per_time_unit": "",
      "give_rate_amount": "",
      "give_rate_units": "",
      "give_strength": "",
      "give_strength_units": "",
      "give_indication": [
        {
          "identifier": "21",
          "text": "内服",
          "name_of_coding_system": "JHSP0003",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "dispense_package_size": "",
      "dispense_package_size_unit": "",
      "dispense_package_method": "",
      "supplementary_code": "",
      "original_order_datetime": "",
      "give_drug_strength_volume": "",
      "give_drug_strength_volume_units": "",
      "controlled_substance_schedule": "",
      "formulary_status": "",
      "pharmaceutical_substance_alternative": "",
      "pharmacy_of_most_recent_fill": "",
      "initial_dispense_amount": "",
      "dispensing_pharmacy": "",
      "dispensing_pharmacy_address": "",
      "deliver_to_patient_location": "",
      "deliver_to_address": "",
      "pharmacy_order_type": ""
    },
    {
      "segment_id": "TQ1",
      "set_id_tq1": "",
      "quantity": "",
      "repeat_pattern": [
        {
          "repeat_pattern_code": {
            "identifier": "1013044400000000",
            "text": "内服・経口・１日３回朝昼夕食後",
            "name_of_coding_system": "JAMISDP01",
            "alternate_identifier": "",
            "alternate_text": "",
            "name_of_alternate_coding_system": "",
            "coding_system_version_id": "",
            "alternate_coding_system_version_id": "",
            "original_text": ""
          },
          "calendar_alignment": "",
          "phase_range_begin_value": "",
          "phase_range_end_value": "",
          "period_quantity": "",
          "period_units": "",
          "institution_specified_time": "",
          "event": "",
          "event_offset_quantity": "",
          "event_offset_units": "",
          "general_timing_specification": ""
        }
      ],
      "explicit_time": "",
      "relative_time_and_units": "",
      "service_duration": [
        {
          "quantity": "3",
          "units": {
            "identifier": "D",
            "text": "日",
            "name_of_coding_system": "ISO+",
            "alternate_identifier": "",
            "alternate_text": "",
            "name_of_alternate_coding_system": "",
            "coding_system_version_id": "",
            "alternate_coding_system_version_id": "",
            "original_text": ""
          }
        }
      ],
      "start_datetime": [
        {
          "time": "20160825",
          "degree_of_precision": ""
        }
      ],
      "end_datetime": "",
      "priority": "",
      "condition_text": "",
      "text_instruction": "",
      "conjunction": "",
      "occurrence_duration": "",
      "total_occurrences": ""
    },
    {
      "segment_id": "RXR",
      "route": [
        {
          "identifier": "PO",
          "text": "口",
          "name_of_coding_system": "HL70162",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "administration_site": "",
      "administration_device": "",
      "administration_method": "",
      "routing_instruction": "",
      "administration_site_modifier": ""
    },
    {
      "segment_id": "ORC",
      "order_control": "NW",
      "placer_order_number": [
        {
          "entity_identifier": "12345678",
          "namespace_id": "",
          "universal_id": "",
          "universal_id_type": ""
        }
      ],
      "filler_order_number": "",
      "placer_group_number": [
        {
          "entity_identifier": "12345678_02",
          "namespace_id": "",
          "universal_id": "",
          "universal_id_type": ""
        }
      ],
      "order_status": "",
      "response_flag": "",
      "quantitytiming": "",
      "parent": "",
      "datetime_of_transaction": [
        {
          "time": "20160825",
          "degree_of_precision": ""
        }
      ],
      "entered_by": "",
      "verified_by": "",
      "ordering_provider": [
        {
          "id_number": "123456",
          "family_name": {
            "surname": "医師",
            "own_surname_prefix": "",
            "own_surname": "",
            "surname_prefix_from_partnerspouse": "",
            "surname_from_partnerspouse": ""
          },
          "given_name": "春子",
          "second_and_further_given_names_or_initials_thereof": "",
          "suffix_eg_jr_or_iii": "",
          "prefix_eg_dr": "",
          "degree_eg_md": "",
          "source_table": "",
          "assigning_authority": "",
          "name_type_code": "L",
          "identifier_check_digit": "",
          "check_digit_scheme": "",
          "identifier_type_code": "",
          "assigning_facility": "",
          "name_representation_code": "I",
          "name_context": "",
          "name_validity_range": "",
          "name_assembly_order": "",
          "effective_date": "",
          "expiration_date": "",
          "professional_suffix": "",
          "assigning_jurisdiction": "",
          "assigning_agency_or_department": ""
        },
        {
          "id_number": "",
          "family_name": {
            "surname": "イシ",
            "own_surname_prefix": "",
            "own_surname": "",
            "surname_prefix_from_partnerspouse": "",
            "surname_from_partnerspouse": ""
          },
          "given_name": "ハルコ",
          "second_and_further_given_names_or_initials_thereof": "",
          "suffix_eg_jr_or_iii": "",
          "prefix_eg_dr": "",
          "degree_eg_md": "",
          "source_table": "",
          "assigning_authority": "",
          "name_type_code": "L",
          "identifier_check_digit": "",
          "check_digit_scheme": "",
          "identifier_type_code": "",
          "assigning_facility": "",
          "name_representation_code": "P",
          "name_context": "",
          "name_validity_range": "",
          "name_assembly_order": "",
          "effective_date": "",
          "expiration_date": "",
          "professional_suffix": "",
          "assigning_jurisdiction": "",
          "assigning_agency_or_department": ""
        }
      ],
      "enterers_location": "",
      "call_back_phone_number": "",
      "order_effective_datetime": "",
      "order_control_code_reason": "",
      "entering_organization": [
        {
          "identifier": "01",
          "text": "内科",
          "name_of_coding_system": "99Z01",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "entering_device": "",
      "action_by": "",
      "advanced_beneficiary_notice_code": "",
      "ordering_facility_name": [
        {
          "organization_name": "メドレークリニック",
          "organization_name_type_code": "",
          "id_number": "",
          "check_digit": "",
          "check_digit_scheme_": "",
          "assigning_authority": "",
          "identifier_type_code": "",
          "assigning_facility": "",
          "name_representation_code": "",
          "organization_identifier": ""
        }
      ],
      "ordering_facility_address": [
        {
          "street_address": "",
          "other_designation": "",
          "city": "港区",
          "state_or_province": "東京都",
          "zip_or_postal_code": "",
          "country": "JPN",
          "address_type": "",
          "other_geographic_designation": "東京都港区六本木３−２−１",
          "countyparish_code": "",
          "census_tract": "",
          "address_representation_code": "",
          "address_validity_range": "",
          "effective_date": "",
          "expiration_date": ""
        }
      ],
      "ordering_facility_phone_number": "",
      "ordering_provider_address": "",
      "order_status_modifier": "",
      "advanced_beneficiary_notice_override_reason": "",
      "fillers_expected_availability_datetime": "",
      "confidentiality_code": "",
      "order_type": [
        {
          "identifier": "O",
          "text": "外来患者オーダ",
          "name_of_coding_system": "HL70482",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "enterer_authorization_mode": ""
    },
    {
      "segment_id": "RXE",
      "quantitytiming": "",
      "give_code": [
        {
          "identifier": "100795402",
          "text": "ボルタレン錠２５ｍｇ",
          "name_of_coding_system": "HOT",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "give_amount_minimum": "1",
      "give_amount_maximum": "",
      "give_units": [
        {
          "identifier": "TAB",
          "text": "錠",
          "name_of_coding_system": "MR9P",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "give_dosage_form": "",
      "providers_administration_instructions": "",
      "deliver_to_location": "",
      "substitution_status": "",
      "dispense_amount": "10",
      "dispense_units": [
        {
          "identifier": "TAB",
          "text": "錠",
          "name_of_coding_system": "MR9P",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "number_of_refills": "",
      "ordering_providers_dea_number": "",
      "pharmacisttreatment_suppliers_verifier_id": "",
      "prescription_number": "",
      "number_of_refills_remaining": "",
      "number_of_refillsdoses_dispensed": "",
      "dt_of_most_recent_refill_or_dose_dispensed": "",
      "total_daily_dose": "",
      "needs_human_review": "",
      "pharmacytreatment_suppliers_special_dispensing_instructions": [
        {
          "identifier": "OHP",
          "text": "外来処方",
          "name_of_coding_system": "MR9P",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        },
        {
          "identifier": "OHI",
          "text": "院内処方",
          "name_of_coding_system": "MR9P",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "give_per_time_unit": "",
      "give_rate_amount": "",
      "give_rate_units": "",
      "give_strength": "",
      "give_strength_units": "",
      "give_indication": [
        {
          "identifier": "22",
          "text": "頓用",
          "name_of_coding_system": "JHSP0003",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "dispense_package_size": "",
      "dispense_package_size_unit": "",
      "dispense_package_method": "",
      "supplementary_code": "",
      "original_order_datetime": "",
      "give_drug_strength_volume": "",
      "give_drug_strength_volume_units": "",
      "controlled_substance_schedule": "",
      "formulary_status": "",
      "pharmaceutical_substance_alternative": "",
      "pharmacy_of_most_recent_fill": "",
      "initial_dispense_amount": "",
      "dispensing_pharmacy": "",
      "dispensing_pharmacy_address": "",
      "deliver_to_patient_location": "",
      "deliver_to_address": "",
      "pharmacy_order_type": ""
    },
    {
      "segment_id": "TQ1",
      "set_id_tq1": "",
      "quantity": "",
      "repeat_pattern": [
        {
          "repeat_pattern_code": {
            "identifier": "1050110020000000",
            "text": "内服・経口・疼痛時",
            "name_of_coding_system": "JAMISDP01",
            "alternate_identifier": "",
            "alternate_text": "",
            "name_of_alternate_coding_system": "",
            "coding_system_version_id": "",
            "alternate_coding_system_version_id": "",
            "original_text": ""
          },
          "calendar_alignment": "",
          "phase_range_begin_value": "",
          "phase_range_end_value": "",
          "period_quantity": "",
          "period_units": "",
          "institution_specified_time": "",
          "event": "",
          "event_offset_quantity": "",
          "event_offset_units": "",
          "general_timing_specification": ""
        }
      ],
      "explicit_time": "",
      "relative_time_and_units": "",
      "service_duration": "",
      "start_datetime": [
        {
          "time": "20160825",
          "degree_of_precision": ""
        }
      ],
      "end_datetime": "",
      "priority": "",
      "condition_text": "",
      "text_instruction": "1 日2 回まで",
      "conjunction": "",
      "occurrence_duration": "",
      "total_occurrences": "10"
    },
    {
      "segment_id": "RXR",
      "route": [
        {
          "identifier": "PO",
          "text": "口",
          "name_of_coding_system": "HL70162",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "administration_site": "",
      "administration_device": "",
      "administration_method": "",
      "routing_instruction": "",
      "administration_site_modifier": ""
    },
    {
      "segment_id": "ORC",
      "order_control": "NW",
      "placer_order_number": [
        {
          "entity_identifier": "12345678",
          "namespace_id": "",
          "universal_id": "",
          "universal_id_type": ""
        }
      ],
      "filler_order_number": "",
      "placer_group_number": [
        {
          "entity_identifier": "12345678_03",
          "namespace_id": "",
          "universal_id": "",
          "universal_id_type": ""
        }
      ],
      "order_status": "",
      "response_flag": "",
      "quantitytiming": "",
      "parent": "",
      "datetime_of_transaction": [
        {
          "time": "20160825",
          "degree_of_precision": ""
        }
      ],
      "entered_by": "",
      "verified_by": "",
      "ordering_provider": [
        {
          "id_number": "123456",
          "family_name": {
            "surname": "医師",
            "own_surname_prefix": "",
            "own_surname": "",
            "surname_prefix_from_partnerspouse": "",
            "surname_from_partnerspouse": ""
          },
          "given_name": "春子",
          "second_and_further_given_names_or_initials_thereof": "",
          "suffix_eg_jr_or_iii": "",
          "prefix_eg_dr": "",
          "degree_eg_md": "",
          "source_table": "",
          "assigning_authority": "",
          "name_type_code": "L",
          "identifier_check_digit": "",
          "check_digit_scheme": "",
          "identifier_type_code": "",
          "assigning_facility": "",
          "name_representation_code": "I",
          "name_context": "",
          "name_validity_range": "",
          "name_assembly_order": "",
          "effective_date": "",
          "expiration_date": "",
          "professional_suffix": "",
          "assigning_jurisdiction": "",
          "assigning_agency_or_department": ""
        },
        {
          "id_number": "",
          "family_name": {
            "surname": "イシ",
            "own_surname_prefix": "",
            "own_surname": "",
            "surname_prefix_from_partnerspouse": "",
            "surname_from_partnerspouse": ""
          },
          "given_name": "ハルコ",
          "second_and_further_given_names_or_initials_thereof": "",
          "suffix_eg_jr_or_iii": "",
          "prefix_eg_dr": "",
          "degree_eg_md": "",
          "source_table": "",
          "assigning_authority": "",
          "name_type_code": "L",
          "identifier_check_digit": "",
          "check_digit_scheme": "",
          "identifier_type_code": "",
          "assigning_facility": "",
          "name_representation_code": "P",
          "name_context": "",
          "name_validity_range": "",
          "name_assembly_order": "",
          "effective_date": "",
          "expiration_date": "",
          "professional_suffix": "",
          "assigning_jurisdiction": "",
          "assigning_agency_or_department": ""
        }
      ],
      "enterers_location": "",
      "call_back_phone_number": "",
      "order_effective_datetime": "",
      "order_control_code_reason": "",
      "entering_organization": [
        {
          "identifier": "01",
          "text": "内科",
          "name_of_coding_system": "99Z01",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "entering_device": "",
      "action_by": "",
      "advanced_beneficiary_notice_code": "",
      "ordering_facility_name": [
        {
          "organization_name": "メドレークリニック",
          "organization_name_type_code": "",
          "id_number": "",
          "check_digit": "",
          "check_digit_scheme_": "",
          "assigning_authority": "",
          "identifier_type_code": "",
          "assigning_facility": "",
          "name_representation_code": "",
          "organization_identifier": ""
        }
      ],
      "ordering_facility_address": [
        {
          "street_address": "",
          "other_designation": "",
          "city": "港区",
          "state_or_province": "東京都",
          "zip_or_postal_code": "",
          "country": "JPN",
          "address_type": "",
          "other_geographic_designation": "東京都港区六本木３−２−１",
          "countyparish_code": "",
          "census_tract": "",
          "address_representation_code": "",
          "address_validity_range": "",
          "effective_date": "",
          "expiration_date": ""
        }
      ],
      "ordering_facility_phone_number": "",
      "ordering_provider_address": "",
      "order_status_modifier": "",
      "advanced_beneficiary_notice_override_reason": "",
      "fillers_expected_availability_datetime": "",
      "confidentiality_code": "",
      "order_type": [
        {
          "identifier": "O",
          "text": "外来患者オーダ",
          "name_of_coding_system": "HL70482",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "enterer_authorization_mode": ""
    },
    {
      "segment_id": "RXE",
      "quantitytiming": "",
      "give_code": [
        {
          "identifier": "106238001",
          "text": "ジフラール軟膏０．０５％",
          "name_of_coding_system": "HOT",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "give_amount_minimum": "\"\"",
      "give_amount_maximum": "",
      "give_units": [
        {
          "identifier": "\"\"",
          "text": "",
          "name_of_coding_system": "",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "give_dosage_form": [
        {
          "identifier": "OIT",
          "text": "軟膏",
          "name_of_coding_system": "MR9P",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "providers_administration_instructions": "",
      "deliver_to_location": "",
      "substitution_status": "",
      "dispense_amount": "2",
      "dispense_units": [
        {
          "identifier": "HON",
          "text": "本",
          "name_of_coding_system": "MR9P",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "number_of_refills": "",
      "ordering_providers_dea_number": "",
      "pharmacisttreatment_suppliers_verifier_id": "",
      "prescription_number": "",
      "number_of_refills_remaining": "",
      "number_of_refillsdoses_dispensed": "",
      "dt_of_most_recent_refill_or_dose_dispensed": "",
      "total_daily_dose": "",
      "needs_human_review": "",
      "pharmacytreatment_suppliers_special_dispensing_instructions": [
        {
          "identifier": "OHP",
          "text": "外来処方",
          "name_of_coding_system": "MR9P",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        },
        {
          "identifier": "OHO",
          "text": "院外処方",
          "name_of_coding_system": "MR9P",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "give_per_time_unit": "",
      "give_rate_amount": "",
      "give_rate_units": "",
      "give_strength": "",
      "give_strength_units": "",
      "give_indication": [
        {
          "identifier": "23",
          "text": "外用",
          "name_of_coding_system": "JHSP0003",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "dispense_package_size": "",
      "dispense_package_size_unit": "",
      "dispense_package_method": "",
      "supplementary_code": "",
      "original_order_datetime": "",
      "give_drug_strength_volume": "",
      "give_drug_strength_volume_units": "",
      "controlled_substance_schedule": "",
      "formulary_status": "",
      "pharmaceutical_substance_alternative": "",
      "pharmacy_of_most_recent_fill": "",
      "initial_dispense_amount": "",
      "dispensing_pharmacy": "",
      "dispensing_pharmacy_address": "",
      "deliver_to_patient_location": "",
      "deliver_to_address": "",
      "pharmacy_order_type": ""
    },
    {
      "segment_id": "TQ1",
      "set_id_tq1": "",
      "quantity": "",
      "repeat_pattern": [
        {
          "repeat_pattern_code": {
            "identifier": "2B74000000000000",
            "text": "外用・塗布・１日４回",
            "name_of_coding_system": "JAMISDP01",
            "alternate_identifier": "",
            "alternate_text": "",
            "name_of_alternate_coding_system": "",
            "coding_system_version_id": "",
            "alternate_coding_system_version_id": "",
            "original_text": ""
          },
          "calendar_alignment": "",
          "phase_range_begin_value": "",
          "phase_range_end_value": "",
          "period_quantity": "",
          "period_units": "",
          "institution_specified_time": "",
          "event": "",
          "event_offset_quantity": "",
          "event_offset_units": "",
          "general_timing_specification": ""
        }
      ],
      "explicit_time": "",
      "relative_time_and_units": "",
      "service_duration": "",
      "start_datetime": [
        {
          "time": "20160825",
          "degree_of_precision": ""
        }
      ],
      "end_datetime": "",
      "priority": "",
      "condition_text": "",
      "text_instruction": "",
      "conjunction": "",
      "occurrence_duration": "",
      "total_occurrences": ""
    },
    {
      "segment_id": "RXR",
      "route": [
        {
          "identifier": "AP",
          "text": "外用",
          "name_of_coding_system": "HL70162",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "administration_site": [
        {
          "identifier": "77L",
          "text": "左手",
          "name_of_coding_system": "JAMISDP01",
          "alternate_identifier": "",
          "alternate_text": "",
          "name_of_alternate_coding_system": "",
          "coding_system_version_id": "",
          "alternate_coding_system_version_id": "",
          "original_text": ""
        }
      ],
      "administration_device": "",
      "administration_method": "",
      "routing_instruction": "",
      "administration_site_modifier": ""
    }
  ]