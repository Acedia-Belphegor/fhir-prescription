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

            it "class" do
                expect(result.local_class.code).to eq "AMB"
            end
        end

        # Organization Resource
        context "Organization" do
            let(:result) { subject.get_resources_from_type("Organization") }

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

            it "code" do
                expect(result.code.first.coding.first.code).to eq "doctor"
            end

            # it "organization" do
            #     id = result.organization.reference.delete("urn:uuid:")
            #     organization = subject.get_resource_from_id(id)
            #     expect(organization.name).to eq "メドレークリニック"
            # end
        end
    end
end