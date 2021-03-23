require './lib/from_qr/qr_fhir_prescription_generator'
require "base64"

RSpec.describe QrFhirPrescriptionGenerator do
  let(:generator) { QrFhirPrescriptionGenerator.new params }

  def params()
    filename = File.join(File.dirname(__FILE__), "qr_example.csv")
    {
      encoding: "Shift_JIS",
      qr_code: Base64.encode64(File.read(filename, encoding: "shift_jis"))
    }
  end

  it 'perform' do
    generator.perform
    # expect(generator.get_resources.entry.count).to eq 18
  end
end