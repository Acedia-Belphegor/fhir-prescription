require './lib/from_cda/cda_fhir_prescription_generator'
require 'nokogiri'

filename = File.join(File.dirname(__FILE__), "example_prescription.xml")

document = Nokogiri::XML.parse(File.read(filename))
document.remove_namespaces!

generator = FhirPrescriptionGenerator.new(document).perform