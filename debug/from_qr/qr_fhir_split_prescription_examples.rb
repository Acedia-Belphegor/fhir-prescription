require "base64"
require './lib/from_qr/qr_fhir_prescription_generator'

def build_codeable_concept(code, display, system = 'LC')
  codeable_concept = FHIR::CodeableConcept.new
  coding = FHIR::Coding.new
  coding.code = code
  coding.display = display
  coding.system = system
  codeable_concept.coding << coding
  codeable_concept
end

params = {
  encoding: "UTF-8",
  qr_code: "SkFISVM1CjEsMSwxMjM0NTY3LDEzLOWMu+eZguazleS6uuOAgOOCquODq+OC\nq+WMu+mZogoyLDExMy0wMDIxLOadseS6rOmDveaWh+S6rOWMuuacrOmnkui+\nvO+8kuKIku+8ku+8mOKIku+8ke+8lgozLDAzLTM5NDYtMDAwMSwwMy0zOTQ2\nLTAwMDIKNCwyLDAxLOWGheenkQo1LCws44OG44K544OI5Yy75birCjExLCzm\ngqPogIXjgIDkuIDpg44s7722776d7728776e772sIO+9su++ge++m++9swox\nMiwxCjEzLDE5NzkxMTAxCjIxLDIKMjIsMTMzOTU5CjIzLO+8ke+8ku+8kyzv\nvJTvvJXvvJYsMQo1MSwyMDIwMTAxNAo2MywzLDEKMTAxLDEsMSwsNjYKMTAy\nLDEsMTEsNjYKMTExLDEsMSws77yR5pel77yT5Zue5pyd5pi85aSV6aOf5b6M\nLAoyMDEsMSwxLDEsNiwxMDA5ODgwMDEs44Ot44Kt44K944OL44Oz6Yyg77yW\n77yQ772N772HLDMsMSzpjKA=\n"
}

client = FHIR::Client.new("http://localhost:8080", default_format: 'json')
client.use_r4
FHIR::Model.client = @client            
bundle = FHIR::Bundle.new
bundle.type = :document

composition = FHIR::Composition.new
composition.id = SecureRandom.uuid
composition.status = :final
composition.type = build_codeable_concept('XX', '分割処方箋(仮)', 'TBD')
composition.date = Time.current
composition.title = "分割処方箋(仮)"
composition.confidentiality = "N"

section = FHIR::Composition::Section.new
section.title = '分割処方箋(仮)'
section.code = build_codeable_concept('XX', '分割処方箋(仮)', 'TBD')
composition.section << section

entry = FHIR::Bundle::Entry.new
entry.resource = composition
bundle.entry << entry

# とりあえず同じ処方箋インスタンスを3つ生成する
prescriptions = 3.times.map{ QrFhirPrescriptionGenerator.new(params).perform.get_params[:bundle] }
bundle.entry.concat prescriptions

section.entry = prescriptions.map{|prescription|
  reference = FHIR::Reference.new
  reference.reference = "#{prescription.resourceType}/#{prescription.id}"
  reference
}

section = FHIR::Composition::Section.new
section.title = '別紙(仮)'
section.code = build_codeable_concept('XX', '別紙(仮)', 'TBD')
composition.section << section

organization = FHIR::Organization.new
organization.id = SecureRandom.uuid

# tel
contact_point = FHIR::ContactPoint.new
contact_point.system = :phone
contact_point.value = "03-3946-0001"
organization.telecom << contact_point

# fax
contact_point = FHIR::ContactPoint.new
contact_point.system = :fax
contact_point.value = "03-3946-0002"
organization.telecom << contact_point

entry = FHIR::Bundle::Entry.new
entry.resource = organization
bundle.entry << entry

reference = FHIR::Reference.new
reference.reference = "#{organization.resourceType}/#{organization.id}"
section.entry << reference

result = bundle.to_json
puts result

__END__

# 原文
JAHIS5
1,1,1234567,13,医療法人　オルカ医院
2,113-0021,東京都文京区本駒込２−２８−１６
3,03-3946-0001,03-3946-0002
4,2,01,内科
5,,,テスト医師
11,,患者　一郎,ｶﾝｼﾞｬ ｲﾁﾛｳ
12,1
13,19791101
21,2
22,133959
23,１２３,４５６,1
51,20201014
63,3,1
101,1,1,,66
102,1,11,66
111,1,1,,１日３回朝昼夕食後,
201,1,1,1,6,100988001,ロキソニン錠６０ｍｇ,3,1,錠

# base64
SkFISVM1CjEsMSwxMjM0NTY3LDEzLOWMu+eZguazleS6uuOAgOOCquODq+OC\nq+WMu+mZogoyLDExMy0wMDIxLOadseS6rOmDveaWh+S6rOWMuuacrOmnkui+\nvO+8kuKIku+8ku+8mOKIku+8ke+8lgozLDAzLTM5NDYtMDAwMSwwMy0zOTQ2\nLTAwMDIKNCwyLDAxLOWGheenkQo1LCws44OG44K544OI5Yy75birCjExLCzm\ngqPogIXjgIDkuIDpg44s7722776d7728776e772sIO+9su++ge++m++9swox\nMiwxCjEzLDE5NzkxMTAxCjIxLDIKMjIsMTMzOTU5CjIzLO+8ke+8ku+8kyzv\nvJTvvJXvvJYsMQo1MSwyMDIwMTAxNAo2MywzLDEKMTAxLDEsMSwsNjYKMTAy\nLDEsMTEsNjYKMTExLDEsMSws77yR5pel77yT5Zue5pyd5pi85aSV6aOf5b6M\nLAoyMDEsMSwxLDEsNiwxMDA5ODgwMDEs44Ot44Kt44K944OL44Oz6Yyg77yW\n77yQ772N772HLDMsMSzpjKA=\n
