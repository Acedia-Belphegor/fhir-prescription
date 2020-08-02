require "base64"
require './lib/from_v2/v2_fhir_prescription_generator'
require_relative 'v2_examples'

params = {
    prefecture_code: "13",
    medical_fee_point_code: "1",
    medical_institution_code: "9999999",
    message: Base64.encode64(get_example_rde_prescription),
}
generator = V2FhirPrescriptionGenerator.new(params).perform
result = generator.get_resources.to_json
puts result