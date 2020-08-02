require './lib/from_cda/cda_fhir_prescription_generator'
require 'nokogiri'

RSpec.describe CdaFhirPrescriptionGenerator do
    let(:generator) { CdaFhirPrescriptionGenerator.new get_document }

    def get_document()
        filename = File.join(File.dirname(__FILE__), "cda_prescription.xml")
        document = Nokogiri::XML.parse(File.read(filename))
        document.remove_namespaces!
    end

    it '#perform' do
        generator.perform
        expect(generator.get_resources.entry.count).to eq 11
    end

    # it 'generate patient' do
    #     generator.perform
    #     entry = generator.get_resources_from_type('Patient').first
    #     expect(entry.resource.name.first.family).to eq '患者'
    #     expect(entry.resource.name.first.given).to eq '太郎'
    # end
end