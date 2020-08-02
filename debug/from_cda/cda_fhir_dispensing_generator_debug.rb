require './lib/from_cda/cda_fhir_dispensing_generator'
require 'nokogiri'

filename = File.join(File.dirname(__FILE__), "cda_dispensing.xml")

document = Nokogiri::XML.parse(File.read(filename))
document.remove_namespaces!

generator = FhirDispensingGenerator.new(document).perform