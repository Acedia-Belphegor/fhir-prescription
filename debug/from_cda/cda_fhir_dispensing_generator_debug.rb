require './lib/from_cda/cda_fhir_dispensing_generator'

filename = File.join(File.dirname(__FILE__), "example_dispensing.xml")
params = {
    encoding: "UTF-8",
    document: Base64.encode64(File.read(filename)),
}
generator = CdaFhirDispensingGenerator.new(params).perform
result = generator.to_json
puts result
