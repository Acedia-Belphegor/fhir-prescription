require "base64"
require './lib/from_qr/qr_fhir_prescription_generator'

filename = File.join(File.dirname(__FILE__), "qr_example.csv")
params = {
    qr_code: Base64.encode64(File.read(filename)),
}
generator = QrFhirPrescriptionGenerator.new(params).perform
result = generator.get_resources.to_json
puts result