require './lib/from_v2/v2_fhir_prescription_generator'
require "base64"

RSpec.describe V2FhirPrescriptionGenerator do
  let(:generator) { V2FhirPrescriptionGenerator.new create_params }

  def create_params()
    filename = File.join(File.dirname(__FILE__), "example_utf8.txt")
    {
      encoding: "utf-8",
      prefecture_code: "13",
      medical_fee_point_code: "1",
      medical_institution_code: "9999999",
      message: Base64.encode64(File.read(filename, encoding: "utf-8"))
    }
  end

  describe "#perform" do
    subject { generator.perform }

    # Patient Resource
    context "Patient" do
      let(:result) { subject.get_resources_from_type("Patient").first }
        
      it "resourceType" do
        expect(result.class).to eq FHIR::Patient
      end

      # 患者番号
      it "identifier" do
        expect(result.identifier.first.value).to eq "1000000001"
      end

      # 患者氏名
      it "name" do
        expect(result.name.count).to eq 2

        result.name.each do |r|
          case r.extension.first.valueCode
          when :IDE
            expect(r.family).to eq "患者"
            expect(r.given.first).to eq "太郎"
          when :SYL
            expect(r.family).to eq "カンジャ"
            expect(r.given.first).to eq "タロウ"
          end
        end
      end

      # 性別
      it "gender" do
        expect(result.gender).to eq :male
      end

      # 生年月日
      it "birthDate" do
        expect(result.birthDate).to eq Date.new(1979, 11, 1)
      end
    end

    # Encounter Resource
    context "Encounter" do
      let(:result) { subject.get_resources_from_type("Encounter").first }

      it "resourceType" do
        expect(result.class).to eq FHIR::Encounter
      end

      it "class" do
        expect(result.local_class.code).to eq "AMB"
      end
    end

    # Organization Resource
    context "Organization" do
      let(:result) { subject.get_resources_from_type("Organization") }

      it "resourceType" do
        expect(result.first.class).to eq FHIR::Organization
      end

      # 医療機関
      it "prov" do
        organization = result.find{|r|r.type.first.coding.first.code == 'prov'}
        expect(organization.name).to eq "メドレークリニック"
      end

      # 診療科
      it "dept" do
        organization = result.find{|r|r.type.first.coding.first.code == 'dept'}
        expect(organization.name).to eq "内科"
      end
    end

    # Practitioner Resource
    context "Practitioner" do
      let(:result) { subject.get_resources_from_type("Practitioner").first }

      it "resourceType" do
        expect(result.class).to eq FHIR::Practitioner
      end

      # 医師氏名
      it "name" do
        expect(result.name.count).to eq 2

        result.name.each do |r|
          case r.extension.first.valueCode
          when :IDE
            expect(r.family).to eq "医師"
            expect(r.given.first).to eq "春子"
          when :SYL
            expect(r.family).to eq "イシ"
            expect(r.given.first).to eq "ハルコ"
          end
        end
      end
    end

    # PractitionerRole Resource
    context "PractitionerRole" do
      let(:result) { subject.get_resources_from_type("PractitionerRole").first }

      it "resourceType" do
        expect(result.class).to eq FHIR::PractitionerRole
      end

      it "code" do
        expect(result.code.first.coding.first.code).to eq "doctor"
      end

      it "organization" do
        id = result.organization.reference.sub(/urn:uuid:/, "")
        organization = subject.get_resource_from_id(id)
        expect(organization.class).to eq FHIR::Organization
        expect(organization.type.first.coding.first.code).to eq "prov"
      end

      it "practitioner" do
        id = result.practitioner.reference.sub(/urn:uuid:/, "")
        practitioner = subject.get_resource_from_id(id)
        expect(practitioner.class).to eq FHIR::Practitioner
      end
    end

    # Coverage Resource
    context "Coverage" do
      let(:result) { subject.get_resources_from_type("Coverage").first }

      it "resourceType" do
        expect(result.class).to eq FHIR::Coverage
      end

      it "type" do
        expect(result.type.coding.first.code).to eq "1" # 社保
      end

      it "relationship" do
        expect(result.relationship.coding.first.code).to eq "1" # 被保険者
      end

      # 保険者
      it "payor" do
        id = result.payor.first.reference.sub(/urn:uuid:/, "")
        organization = subject.get_resource_from_id(id)
        expect(organization.class).to eq FHIR::Organization
        expect(organization.identifier.first.value).to eq "06050116"
      end
    end

    # MedicationRequest Resource
    context "MedicationRequest" do
      let(:result) { subject.get_resources_from_type("MedicationRequest") }

      it "resourceType" do
        expect(result.first.class).to eq FHIR::MedicationRequest
      end

      context "内服薬" do
        let(:mr) { result.select{|mr|mr.identifier.select{|id|id.system == 'urn:oid:1.2.392.100495.20.3.81'}.first.value == '01'}.first }

        # 医薬品
        it "medicationCodeableConcept" do
          expect(mr.medicationCodeableConcept.coding.first.code).to eq "103835401"
          expect(mr.medicationCodeableConcept.coding.first.display).to eq "ムコダイン錠２５０ｍｇ"
        end

        # 患者
        it "subject" do
          id = mr.subject.reference.sub(/urn:uuid:/, "")
          patient = subject.get_resource_from_id(id)
          expect(patient.class).to eq FHIR::Patient
        end

        # 用法
        context "dosageInstruction" do
          let(:dosage) { mr.dosageInstruction.first }

          it "timing" do
            expect(dosage.timing.code.coding.first.code).to eq "1013044400000000"
            expect(dosage.timing.code.coding.first.display).to eq "内服・経口・１日３回朝昼夕食後"
          end

          it "method" do
            expect(dosage.local_method.coding.first.code).to eq "21"
            expect(dosage.local_method.coding.first.display).to eq "内服"
          end

          it "doseAndRate" do
            # 1回量
            expect(dosage.doseAndRate.first.doseQuantity.value).to eq 1
            expect(dosage.doseAndRate.first.doseQuantity.unit).to eq "錠"

            # 1日量
            expect(dosage.doseAndRate.first.rateRatio.numerator.value).to eq 3
            expect(dosage.doseAndRate.first.rateRatio.numerator.unit).to eq "錠"
            expect(dosage.doseAndRate.first.rateRatio.denominator.value).to eq 1
            expect(dosage.doseAndRate.first.rateRatio.denominator.unit).to eq "日"
          end
        end

        # 調剤指示
        context "dispenseRequest" do
          let(:dispenseRequest) { mr.dispenseRequest }

          # 調剤量
          it "quantity" do
            expect(dispenseRequest.quantity.value).to eq 9
            expect(dispenseRequest.quantity.unit).to eq "錠"
          end

          # 払い出し日数
          it "expectedSupplyDuration" do
            expect(dispenseRequest.expectedSupplyDuration.value).to eq 3
            expect(dispenseRequest.expectedSupplyDuration.unit).to eq "日"
          end
        end
      end

      context "外用薬" do
        let(:mr) { result.select{|mr|mr.identifier.select{|id|id.system == 'urn:oid:1.2.392.100495.20.3.81'}.first.value == '02'}.first }

        # 医薬品
        it "medicationCodeableConcept" do
          expect(mr.medicationCodeableConcept.coding.first.code).to eq "106238001"
          expect(mr.medicationCodeableConcept.coding.first.display).to eq "ジフラール軟膏０．０５％"
        end

        # 用法
        context "dosageInstruction" do
          let(:dosage) { mr.dosageInstruction.first }

          it "method" do
            expect(dosage.local_method.coding.first.code).to eq "23"
            expect(dosage.local_method.coding.first.display).to eq "外用"
          end
        end
      end

      context "座薬" do
        let(:mr) { result.select{|mr|mr.identifier.select{|id|id.system == 'urn:oid:1.2.392.100495.20.3.81'}.first.value == '03'}.first }

        # 医薬品
        it "medicationCodeableConcept" do
          expect(mr.medicationCodeableConcept.coding.first.code).to eq "105625901"
          expect(mr.medicationCodeableConcept.coding.first.display).to eq "ボラギノールＮ坐薬"
        end

        # 用法
        context "dosageInstruction" do
          let(:dosage) { mr.dosageInstruction.first }

          it "method" do
            expect(dosage.local_method.coding.first.code).to eq "23"
            expect(dosage.local_method.coding.first.display).to eq "外用"
          end

          it "doseAndRate" do
            # 1回量
            expect(dosage.doseAndRate.first.doseQuantity.value).to eq 1
            expect(dosage.doseAndRate.first.doseQuantity.unit).to eq "個"

            # 1日量
            expect(dosage.doseAndRate.first.rateRatio.numerator.value).to eq 2
            expect(dosage.doseAndRate.first.rateRatio.numerator.unit).to eq "個"
            expect(dosage.doseAndRate.first.rateRatio.denominator.value).to eq 1
            expect(dosage.doseAndRate.first.rateRatio.denominator.unit).to eq "日"
          end
        end
      end

      context "麻薬" do
        let(:mr) { result.select{|mr|mr.identifier.select{|id|id.system == 'urn:oid:1.2.392.100495.20.3.81'}.first.value == '04'}.first }

        # 医薬品
        it "medicationCodeableConcept" do
          expect(mr.medicationCodeableConcept.coding.first.code).to eq "112052301"
          expect(mr.medicationCodeableConcept.coding.first.display).to eq "ＭＳコンチン錠１０ｍｇ"
        end

        # 麻薬施用者番号
        it "practitioner.qualification" do
          practitioner = subject.get_resources_from_type("Practitioner").first
          expect(practitioner.qualification.first.identifier.value).to eq "4-321"
        end
      end

      context "頓服薬" do
        let(:mr) { result.select{|mr|mr.identifier.select{|id|id.system == 'urn:oid:1.2.392.100495.20.3.81'}.first.value == '05'}.first }

        # 医薬品
        it "medicationCodeableConcept" do
          expect(mr.medicationCodeableConcept.coding.first.code).to eq "100795402"
          expect(mr.medicationCodeableConcept.coding.first.display).to eq "ボルタレン錠２５ｍｇ"
        end

        # 用法
        context "dosageInstruction" do
          let(:dosage) { mr.dosageInstruction.first }

          it "method" do
            expect(dosage.local_method.coding.first.code).to eq "22"
            expect(dosage.local_method.coding.first.display).to eq "頓用"
          end

          it "asNeededBoolean" do
            expect(dosage.asNeededBoolean).to eq true
          end

          it "doseAndRate" do
            # 1回量
            expect(dosage.doseAndRate.first.doseQuantity.value).to eq 1
            expect(dosage.doseAndRate.first.doseQuantity.unit).to eq "錠"
          end
        end

        # 調剤指示
        context "dispenseRequest" do
          let(:dispenseRequest) { mr.dispenseRequest }

          # 調剤量
          it "quantity" do
            expect(dispenseRequest.quantity.value).to eq 10
            expect(dispenseRequest.quantity.unit).to eq "錠"
          end

          # 払い出し回数
          it "extension.expectedRepeatCount" do
            expect(dispenseRequest.extension.first.valueInteger).to eq 10
          end
        end
      end

      context "漸増（漸減）投与" do
        let(:mrs) { result.select{|mr|mr.identifier.select{|id|id.system == 'urn:oid:1.2.392.100495.20.3.81'}.first.value == '06'} }

        it "works" do
          mrs.sort_by{|mr|mr.identifier.select{|id|id.system == 'urn:oid:1.2.392.100495.20.3.82'}.first.value.to_i}.each do |mr|
            # 医薬品
            expect(mr.medicationCodeableConcept.coding.first.code).to eq "101230901"
            expect(mr.medicationCodeableConcept.coding.first.display).to eq "ペルマックス錠５０μｇ"

            dosage = mr.dosageInstruction.first

            case mr.identifier.select{|id|id.system == 'urn:oid:1.2.392.100495.20.3.82'}.first.value.to_i
            when 1
              expect(dosage.timing.repeat.boundsPeriod.start).to eq Date.new(2016, 8, 25)
              expect(dosage.doseAndRate.first.doseQuantity.value).to eq 1
            when 2
              expect(dosage.timing.repeat.boundsPeriod.start).to eq Date.new(2016, 8, 27)
              expect(dosage.doseAndRate.first.doseQuantity.value).to eq 2
            when 3
              expect(dosage.timing.repeat.boundsPeriod.start).to eq Date.new(2016, 8, 30)
              expect(dosage.doseAndRate.first.doseQuantity.value).to eq 3
            end
          end
        end
      end

      context "隔日投与" do
        let(:mr) { result.select{|mr|mr.identifier.select{|id|id.system == 'urn:oid:1.2.392.100495.20.3.81'}.first.value == '07'}.first }

        # 医薬品
        it "medicationCodeableConcept" do
          expect(mr.medicationCodeableConcept.coding.first.code).to eq "105271807"
          expect(mr.medicationCodeableConcept.coding.first.display).to eq "プレドニン錠５ｍｇ"
        end

        # 用法
        context "dosageInstruction" do
          let(:dosage) { mr.dosageInstruction.first }

          it "additionalInstruction" do
            expect(dosage.additionalInstruction.first.coding.first.code).to eq "I1100000" # １日おき
          end
        end
      end

      context "曜日指定投与" do 
        let(:mr) { result.select{|mr|mr.identifier.select{|id|id.system == 'urn:oid:1.2.392.100495.20.3.81'}.first.value == '08'}.first }

        # 医薬品
        it "medicationCodeableConcept" do
          expect(mr.medicationCodeableConcept.coding.first.code).to eq "105271807"
          expect(mr.medicationCodeableConcept.coding.first.display).to eq "プレドニン錠５ｍｇ"
        end

        # 用法
        context "dosageInstruction" do
          let(:dosage) { mr.dosageInstruction.first }

          it "additionalInstruction" do
            expect(dosage.additionalInstruction.first.coding.first.code).to eq "W0100100" # 月曜日、木曜日
          end
        end
      end

      context "不均等投与" do
        let(:mr) { result.select{|mr|mr.identifier.select{|id|id.system == 'urn:oid:1.2.392.100495.20.3.81'}.first.value == '09'}.first }

        # 医薬品
        it "medicationCodeableConcept" do
          expect(mr.medicationCodeableConcept.coding.first.code).to eq "105271807"
          expect(mr.medicationCodeableConcept.coding.first.display).to eq "プレドニン錠５ｍｇ"
        end

        # 用法
        context "dosageInstruction" do
          let(:dosage) { mr.dosageInstruction.first }

          it "extension.SubInstruction" do
            dosage.extension.each do |sub_instruction|
              case sub_instruction.valueDosage.sequence
              when 1
                expect(sub_instruction.valueDosage.doseAndRate.first.doseQuantity.value).to eq 4
              when 2
                expect(sub_instruction.valueDosage.doseAndRate.first.doseQuantity.value).to eq 2
              when 3
                expect(sub_instruction.valueDosage.doseAndRate.first.doseQuantity.value).to eq 1
              end
            end
          end
        end
      end

      context "交互投与" do
        let(:mrs) { result.select{|mr|mr.identifier.select{|id|id.system == 'urn:oid:1.2.392.100495.20.3.81'}.first.value == '10'} }

        it "works" do
          mrs.sort_by{|mr|mr.identifier.select{|id|id.system == 'urn:oid:1.2.392.100495.20.3.82'}.first.value.to_i}.each do |mr|
            # 医薬品
            expect(mr.medicationCodeableConcept.coding.first.code).to eq "105271807"
            expect(mr.medicationCodeableConcept.coding.first.display).to eq "プレドニン錠５ｍｇ"

            dosage = mr.dosageInstruction.first

            case mr.identifier.select{|id|id.system == 'urn:oid:1.2.392.100495.20.3.82'}.first.value.to_i
            when 1
              expect(dosage.additionalInstruction.first.coding.first.code).to eq "I1100000" # １日おき
              expect(dosage.timing.repeat.boundsPeriod.start).to eq Date.new(2016, 8, 25)
              expect(dosage.doseAndRate.first.doseQuantity.value).to eq 3
            when 2
              expect(dosage.additionalInstruction.first.coding.first.code).to eq "I1100000" # １日おき
              expect(dosage.timing.repeat.boundsPeriod.start).to eq Date.new(2016, 8, 26)
              expect(dosage.doseAndRate.first.doseQuantity.value).to eq 1
            end
          end
        end
      end

      context "在宅自己注射" do
        let(:mr) { result.select{|mr|mr.identifier.select{|id|id.system == 'urn:oid:1.2.392.100495.20.3.81'}.first.value == '11'}.first }

        # 医薬品
        it "medicationCodeableConcept" do
          expect(mr.medicationCodeableConcept.coding.first.code).to eq "105466802"
          expect(mr.medicationCodeableConcept.coding.first.display).to eq "ヒューマリンＮ注１００単位／ｍＬ"
        end

        # 用法
        context "dosageInstruction" do
          let(:dosage) { mr.dosageInstruction.first }

          it "method" do
            expect(dosage.local_method.coding.first.code).to eq "24"
            expect(dosage.local_method.coding.first.display).to eq "自己注射"
          end
        end
      end
    end
  end
end