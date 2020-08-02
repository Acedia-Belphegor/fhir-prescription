require_relative 'v2_generate_abstract'

class V2GenerateMedicationRequest < V2GenerateAbstract
    def perform()
        section = FHIR::Composition::Section.new
        section.title = '処方指示'
        section.code = create_codeable_concept('01', '処方指示', 'urn:oid:1.2.392.100495.20.2.12')

        results = []

        get_segment_groups.each do |segments|
            medication_request = FHIR::MedicationRequest.new
            medication_request.id = SecureRandom.uuid
            medication_request.status = :draft
            medication_request.intent = :order
            dosage = FHIR::Dosage.new
            dosage.timing = FHIR::Timing.new
            medication_request.dosageInstruction << dosage
           
            # ORC
            orc_segment = segments.find{|segment|segment[:segment_id] == 'ORC'}

            # ORC-2.依頼者オーダ番号
            medication_request.identifier << generate_identifier(orc_segment[:placer_order_number].first[:entity_identifier], 'urn:oid:1.2.392.100495.20.3.11')
            # ORC-4.依頼者グループ番号
            medication_request.identifier << generate_identifier(orc_segment[:placer_group_number].first[:entity_identifier], 'urn:oid:1.2.392.100495.20.3.81')
            # ORC-9.トランザクション日時(交付年月日)
            medication_request.authoredOn = Date.parse(orc_segment[:datetime_of_transaction].first[:time]) if orc_segment[:datetime_of_transaction].present?
            # ORC-29.オーダタイプ
            medication_request.category << generate_codeable_concept(orc_segment[:order_type].first)

            # RXE
            rxe_segment = segments.find{|segment|segment[:segment_id] == 'RXE'}

            # RXE-2.与薬コード
            codeable_concept = generate_codeable_concept(rxe_segment[:give_code].first)
            system = codeable_concept.coding.first.system
            codeable_concept.coding.first.system = 
                case system
                when 'HOT' then 'urn:oid:1.2.392.100495.20.2.74' # HOTコード
                else system
                end
            medication_request.medicationCodeableConcept = codeable_concept

            # RXE-3.与薬量－最小 / RXE-5.与薬単位
            if rxe_segment[:give_amount_minimum].to_f.positive?
                dose = FHIR::Dosage::DoseAndRate.new
                quantity = FHIR::Quantity.new
                quantity.value = rxe_segment[:give_amount_minimum].to_f
                quantity.code = rxe_segment[:give_units].first[:identifier]
                quantity.unit = rxe_segment[:give_units].first[:text]
                dose.doseQuantity = quantity
                dosage.doseAndRate << dose
            end

            # RXE-6.与薬剤型
            medication_request.category << generate_codeable_concept(rxe_segment[:give_dosage_form].first)

            # RXE-7.依頼者の投薬指示
            if rxe_segment[:providers_administration_instructions].present?
                dosage.additionalInstruction = rxe_segment[:providers_administration_instructions].map{|element|generate_codeable_concept(element)}
            end

            # RXE-10.調剤量 / RXE-11.調剤単位
            if rxe_segment[:dispense_amount].to_f.positive?
                dispense_request = FHIR::MedicationRequest::DispenseRequest.new
                quantity = FHIR::Quantity.new
                quantity.value = rxe_segment[:dispense_amount].to_f
                quantity.code = rxe_segment[:dispense_units].first[:identifier]
                quantity.unit = rxe_segment[:dispense_units].first[:text]
                dispense_request.quantity = quantity
                medication_request.dispenseRequest = dispense_request
            end

            # RXE-15.処方箋番号
            medication_request.identifier << generate_identifier(rxe_segment[:prescription_number], 'urn:oid:1.2.392.100495.20.3.11') if rxe_segment[:prescription_number].present?

            # RXE-19.1日あたりの総投与量
            extension = FHIR::Extension.new
            extension.url = "http://hl7fhir.jp/fhir/StructureDefinition/Extension-JPCore-TotalDailyDose"
            extension.valueQuantity = generate_quantity(rxe_segment[:total_daily_dose].first)
            dosage.extension << extension

            # RXE-21.薬剤部門/治療部門による特別な調剤指示
            if rxe_segment[:pharmacytreatment_suppliers_special_dispensing_instructions].present?
                medication_request.category.concat rxe_segment[:pharmacytreatment_suppliers_special_dispensing_instructions].map{|element|generate_codeable_concept(element)}
            end

            # RXE-27.与薬指示
            if rxe_segment[:give_indication].present?
                codeable_concept = generate_codeable_concept(rxe_segment[:give_indication].first)
                medication_request.category << codeable_concept
    
                if codeable_concept.coding.first.code == '22' # 頓用
                    dosage.asNeededBoolean = true
                end
            end

            # TQ1
            tq1_segment = segments.find{|segment|segment[:segment_id] == 'TQ1'}

            # TQ1-3.繰返しパターン(用法)
            tq1_segment[:repeat_pattern].each do |element|
                codeable_concept = generate_codeable_concept(element[:repeat_pattern_code])
                if dosage.timing.code.nil?
                    dosage.timing.code = [codeable_concept] # 1つ目の用法は timing に設定する
                else
                    dosage.additionalInstruction << codeable_concept # 2つ目以降の用法は additionalInstruction に設定する
                end
            end

            # 可読部の編集
            dosage.text = tq1_segment[:repeat_pattern].map{|element|element[:repeat_pattern_code][:text]}.join("　")

            # TQ1-6.サービス期間(投薬日数)
            if tq1_segment[:service_duration].present?
                timing_repeat = FHIR::Timing::Repeat.new
                timing_repeat.duration = tq1_segment[:service_duration].first[:quantity].to_i
                timing_repeat.durationUnit = 'd'
                dosage.timing.repeat = timing_repeat
            end

            # TQ1-7.開始日時
            dosage.timing.event << tq1_segment[:start_datetime].first[:time]
            # TQ1-11.テキスト指令
            dosage.patientInstruction = tq1_segment[:text_instruction]

            # TQ1-14.事象総数(頓用指示の回数)
            if tq1_segment[:total_occurrences].present?
                timing_repeat = FHIR::Timing::Repeat.new
                timing_repeat.count = tq1_segment[:total_occurrences].to_i
                dosage.timing.repeat = timing_repeat
            end

            # RXR
            rxr_segment = segments.find{|segment|segment[:segment_id] == 'RXR'}

            # RXR-1.経路
            dosage.route = generate_codeable_concept(rxr_segment[:route].first) if rxr_segment[:route].present?
            # RXR-2.部位
            dosage.site = generate_codeable_concept(rxr_segment[:administration_site].first) if rxr_segment[:administration_site].present?
            # RXR-4.投薬方法
            dosage.local_method = generate_codeable_concept(rxr_segment[:administration_method].first) if rxr_segment[:administration_method].present?

            # 不均等投与
            imbalances = dosage.additionalInstruction.map{|element|element.coding.select{|element|element.code.match(/^V[1-9][0-9.N]+$/) && element.system == 'JAMISDP01'}}.compact.reject(&:empty?)
            if imbalances.count.positive?
                imbalance_doses = []
                imbalances.each do |imbalance|
                    quantity = FHIR::Quantity.new
                    quantity.value = imbalance.first.code.slice(2..-1).delete('N').to_i
                    quantity.code = dosage.doseAndRate.first.doseQuantity.code
                    quantity.unit = dosage.doseAndRate.first.doseQuantity.unit
                    dose = FHIR::Dosage::DoseAndRate.new
                    dose.type = imbalance
                    dose.doseQuantity = quantity
                    imbalance_doses << dose
                end
                dosage.doseAndRate = imbalance_doses
                dosage.additionalInstruction.delete_if{ |c| imbalances.include?(c.coding) }
            end

            # Patientリソースの参照
            medication_request.subject = create_reference(get_resources_from_type('Patient').first.resource)
            # PractitionerRoleリソースの参照
            medication_request.requester = create_reference(get_resources_from_type('PractitionerRole').first.resource)
            # Coverageリソースの参照
            medication_request.insurance = get_resources_from_type('Coverage').map{ |coverage| create_reference(coverage.resource) }

            section.entry << create_reference(medication_request)

            entry = FHIR::Bundle::Entry.new
            entry.resource = medication_request
            results << entry
        end

        composition = get_composition.resource
        composition.section << section
        results
    end

    private
    def get_segment_groups()
        result = []
        segments = []

        # ORC,RXE,TQ1,RXRを1つのグループにまとめて配列を生成する
        get_message.select{|segment|segment[:segment_id].in? %w[ORC RXE TQ1 RXR]}.each do |segment|
            # ORCの出現を契機に配列を作成する
            if segment[:segment_id] == 'ORC'
                result << segments if segments.present?
                segments = []
            end
            segments << segment
        end
        result << segments if segments.present?
        result
    end
end