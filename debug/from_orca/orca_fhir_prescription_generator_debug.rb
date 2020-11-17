require "base64"
require './lib/from_orca/orca_fhir_prescription_generator'

params = File.read(File.join(File.dirname(__FILE__), "shohosen.json"), encoding: "utf-8")
generator = OrcaFhirPrescriptionGenerator.new(params).perform
result = generator.get_resources.to_json
puts result
