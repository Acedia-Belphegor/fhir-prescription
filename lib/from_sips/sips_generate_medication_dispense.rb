require_relative 'sips_generate_abstract'

class SipsGenerateMedicationDispense < SipsGenerateAbstract
    def perform()
        section = FHIR::Composition::Section.new
        section.title = '調剤結果ボディ'
        section.code = create_codeable_concept('12', '調剤結果ボディ', 'TBD')

        medication_records = get_records(MEDICATION)
        return unless medication_records.present?
        results = []

        medication_records.each do |medication_record|
            medication_dispense = FHIR::MedicationDispense.new
            medication_dispense.id = SecureRandom.uuid
            medication_dispense.status = :unknown
            dosage = FHIR::Dosage.new
            dosage.timing = FHIR::Timing.new
            medication_dispense.dosageInstruction << dosage

            # 用法部
            dosage_record = get_records(DOSAGE).find{|r|r[:rp_number] == medication_record[:rp_number]}
            next unless dosage_record.present?

            # RP番号
            medication_dispense.identifier << generate_identifier(medication_record[:rp_number].to_i, 'urn:oid:1.2.392.100495.20.3.81')
            # 薬品番号
            medication_dispense.identifier << generate_identifier(medication_record[:medication_number].to_i, 'urn:oid:1.2.392.100495.20.3.xx')

            codeable_concept = FHIR::CodeableConcept.new
            # YJコード
            codeable_concept.coding << create_coding(medication_record[:yj_code], nil, 'urn:oid:1.2.392.100495.20.2.73')
            # レセ電算コード
            codeable_concept.coding << create_coding(medication_record[:receipt_code], nil, 'urn:oid:1.2.392.100495.20.2.71') if medication_record[:receipt_code].present?
            # HOTコード
            codeable_concept.coding << create_coding(medication_record[:hot_code], nil, 'urn:oid:1.2.392.100495.20.2.74') if medication_record[:hot_code].present?
            # 明細コード（レセコンに登録されている薬品コード）
            codeable_concept.coding << create_coding(medication_record[:medication_code], nil)
            # 薬品名
            codeable_concept.text = medication_record[:medication_name]
            
            dose = FHIR::Dosage::DoseAndRate.new
            # 1回服用量
            if medication_record[:one_time_dose_quantity].present?
                dose.doseQuantity = create_quantity(medication_record[:one_time_dose_quantity].to_f, medication_record[:units])
            end

            # 服用量(1日量)
            ratio = FHIR::Ratio.new
            ratio.numerator = create_quantity(medication_record[:dose_quantity].to_f, medication_record[:units])
            ratio.denominator = create_quantity(1, "d")
            dose.rateRatio = ratio

            # 力価フラグ
            dose.type = create_codeable_concept(
                medication_record[:strength_flag],
                (medication_record[:strength_flag] == '1' ? '製剤量' : '原薬量'),
                'urn:oid:1.2.392.100495.20.2.22'
            )
            dosage.doseAndRate << dose

            # 投与日数/回数
            if dosage_record[:days_or_times_class] == '1'
                # 日数
                extension = FHIR::Extension.new
                extension.url = "http://hl7fhir.jp/fhir/StructureDefinition/Extension-JPCore-xxx"
                duration = FHIR::Duration.new
                duration.value = dosage_record[:days_or_times].to_i
                duration.unit = 'd'
                extension.valueDuration = duration
                medication_dispense.extension << extension
            else
                # 回数
                extension = FHIR::Extension.new
                extension.url = "http://hl7fhir.jp/fhir/StructureDefinition/Extension-JPCore-xxx"
                extension.valueInteger = dosage_record[:days_or_times].to_i
                medication_dispense.extension << extension
                # 頓用
                dosage.asNeededBoolean = true if dosage_record[:rp_class] == '3'
            end

            # 用法1
            dosage.timing.code = create_codeable_concept(dosage_record[:dosage_code1], dosage_record[:dosage_name1])

            # 用法2
            if dosage_record[:dosage_code2].present?
                dosage.additionalInstruction << create_codeable_concept(dosage_record[:dosage_code2], dosage_record[:dosage_name2])
            end

            # 用法3
            if dosage_record[:dosage_code3].present?
                dosage.additionalInstruction << create_codeable_concept(dosage_record[:dosage_code3], dosage_record[:dosage_name3])
            end

            timing_repeat = FHIR::Timing::Repeat.new
            # 服用回数
            timing_repeat.frequency = dosage_record[:days_or_times].to_i
            timing_repeat.period = 1
            timing_repeat.periodUnit = 'd'
            # 服用開始日
            period = FHIR::Period.new
            period.start = dosage_record[:start_date]
            timing_repeat.boundsPeriod = period
            dosage.timing.repeat = timing_repeat

            # 後発品変更前薬品
            before_change_generics = [
                { code: medication_record[:before_change_generic_yj_code], system: 'urn:oid:1.2.392.100495.20.2.73' }, # YJコード
                { code: medication_record[:before_change_generic_receipt_code], system: 'urn:oid:1.2.392.100495.20.2.71' }, # レセ電算コード
                { code: medication_record[:before_change_generic_hot_code], system: 'urn:oid:1.2.392.100495.20.2.74' }, # HOTコード
            ].compact.reject{|c|c[:code].blank?}
    
            substitution = FHIR::MedicationDispense::Substitution.new
            # 一般名処方フラグ
            if medication_record[:generic_flag] == '1'
                substitution.type = create_codeable_concept('E','equivalent','http://terminology.hl7.org/ValueSet/v3-ActSubstanceAdminSubstitutionCode')
            end
            if before_change_generics.present?
                # 後発品変更前薬品
                extension = FHIR::Extension.new
                extension.url = "http://hl7fhir.jp/fhir/StructureDefinition/Extension-JPCore-BeforeChangeGenericMedication"
                codeable_concept = FHIR::CodeableConcept.new
                codeable_concept.coding = before_change_generics.map{|c|create_coding(c[:code], nil, c[:system])}
                codeable_concept.text = medication_record[:before_change_generic_medication_name]
                extension.valueCodeableConcept = codeable_concept
                substitution.extension << extension

                # 後発品変更前薬品 服用量／単位
                extension = FHIR::Extension.new
                extension.url = "http://hl7fhir.jp/fhir/StructureDefinition/Extension-JPCore-BeforeChangeGenericDoseQuantity"
                extension.valueQuantity = create_quantity(medication_record[:before_change_generic_dose_quantity].to_f, medication_record[:before_change_generic_units])
                substitution.extension << extension            

                substitution.wasSubstituted = true                
            else
                substitution.wasSubstituted = false
            end
            medication_dispense.substitution = substitution

            # 不均等
            imbalances = [
                medication_record[:imbalance_quantity1], # 起床時
                medication_record[:imbalance_quantity2], # 朝
                medication_record[:imbalance_quantity3], # 昼
                medication_record[:imbalance_quantity4], # 夕
                medication_record[:imbalance_quantity5], # 寝る前
                medication_record[:imbalance_quantity6], # 予備
            ]
            imbalances.map(&:to_f).select(&:positive?).each_with_index do |imbalance, idx|
                extension = FHIR::Extension.new
                extension.url = "http://hl7fhir.jp/fhir/StructureDefinition/Extension-JPCore-xxx"
                imbalance_dosage = FHIR::Dosage.new
                imbalance_dosage.sequence = idx + 1
                imbalance_code = "V#{idx+1}#{"%.15g"%imbalance}"
                imbalance_dosage.additionalInstruction = create_codeable_concept(
                    imbalance_code + ("N" * (8 - imbalance_code.length)), # JAMI補足用法コード (V + 服用順 + 服用量 + N) ex:V13NNNNN
                    nil,
                    'urn:oid:1.2.392.100495.20.2.32'
                )
                imbalance_dose = FHIR::Dosage::DoseAndRate.new
                imbalance_dose.doseQuantity = create_quantity(imbalance.to_f, medication_record[:units])
                imbalance_dosage.doseAndRate << imbalance_dose
                extension.valueDosage = imbalance_dosage
                dosage.extension << extension
            end

            # Patientリソースの参照
            medication_dispense.subject = create_reference(get_resources_from_type('Patient').first.resource)

            section.entry << create_reference(medication_dispense)

            entry = FHIR::Bundle::Entry.new
            entry.resource = medication_dispense
            results << entry
        end

        composition = get_composition.resource
        composition.section << section
        results
    end
end