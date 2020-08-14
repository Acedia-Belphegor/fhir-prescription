require './lib/from_cda/cda_fhir_prescription_generator'
require 'nokogiri'

RSpec.describe CdaFhirPrescriptionGenerator do
    let(:generator) { CdaFhirPrescriptionGenerator.new params }

    def params()
        filename = File.join(File.dirname(__FILE__), "example_prescription.xml")
        {
            encoding: "UTF-8",
            document: Base64.encode64(File.read(filename))
        }
    end

    it '#perform' do
        generator.perform
        expect(generator.get_resources.entry.count).to eq 11
    end
end