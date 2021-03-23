require 'openssl'
require 'base64'

class GenerateSignature
  def initialize(target_bundle)
    @target_bundle = target_bundle
  end

  def perform()
    signature = FHIR::Signature.new
    
    coding = FHIR::Coding.new
    coding.code = "1.2.840.10065.1.12.1.1"
    coding.display = "Author's Signature"
    coding.system = "urn:iso-astm:E1762-95:2013"
    signature.type = FHIR::CodeableConcept.new
    signature.type.coding << coding

    signature.when = Time.current

    practitioner = @target_bundle.entry.select{|e|e.resource.resourceType == "Practitioner"}.map{|e|e.resource}&.first
    if practitioner.present?
      signature.who = FHIR::Reference.new
      signature.who.reference = "urn:uuid:#{practitioner.id}"
    end

    secret_key = 'hoge'
    token = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), secret_key, @target_bundle.to_json)
    signature.data = Base64.encode64(token)

    @target_bundle.signature = signature
  end
end