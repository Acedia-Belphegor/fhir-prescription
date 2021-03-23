require 'json'
require 'csv'
require 'pathname'

class QrCodeParser
  def initialize(qr_code)
    @qr_code = qr_code
    
    # JAHIS院外処方箋２次元シンボル記録条件規約のフォーマットファイルを読み込む
    @jahis_format = File.open(Pathname.new(File.dirname(File.expand_path(__FILE__))).join('json').join('jahis_format.json')) do |io|
      JSON.load(io, nil, {:symbolize_names => true, :create_additions => false})
    end
  end

  def parse()
    results = []

    @qr_code.split("\n").each do |record|
      next if record.upcase.start_with?('JAHIS')
      record_number = record.split(/,/).first.to_i
      formats = @jahis_format[:records].find{|r|r[:record_number] == record_number}
      next unless formats.present?
      results.concat CSV.parse(record, headers: formats[:rayout].map{|r|r[:name].to_sym}.unshift(:record_number)).map(&:to_hash)
    end

    @parsed_qr = results
  end
end
__END__
[
    {
      "record_number": "1",
      "medical_institution_code_kind": "1",
      "medical_institution_code": "1234567",
      "medical_institution_prefecture_code": "13",
      "medical_institution_name": "医療法人社団ｘｙｚ会　オルカクリニック"
    },
    {
      "record_number": "2",
      "medical_institution_postalcode": "113-0021",
      "medical_institution_address": "東京都文京区本駒込２−２８−１６　ほげほげビル９９Ｆ"
    },
    {
      "record_number": "3",
      "medical_institution_tel": "03-3946-0001",
      "medical_institution_fax": "03-3946-0002",
      "medical_institution_other_contact": null
    },
    {
      "record_number": "4",
      "department_code_kind": "2",
      "department_code": "01",
      "department_name": "内科"
    },
    {
      "record_number": "5",
      "doctor_code": null,
      "doctor_kana_name": null,
      "doctor_kanji_name": "テスト医師"
    },
    {
      "record_number": "11",
      "patient_code": null,
      "patient_kanji_name": "九亜流　花子",
      "patient_kana_name": "ｷｭｳｱｰﾙ ﾊﾅｺ"
    },
    {
      "record_number": "12",
      "patient_gender": "2"
    },
    {
      "record_number": "13",
      "patient_birthdate": "19671012"
    },
    {
      "record_number": "21",
      "insurance_kind": "1"
    },
    {
      "record_number": "22",
      "insurer_number": "06270409"
    },
    {
      "record_number": "23",
      "insured_symbol": null,
      "insured_number": null,
      "relationship": "1"
    },
    {
      "record_number": "27",
      "identification_number": "21136791",
      "recipient_number": "6247373"
    },
    {
      "record_number": "51",
      "delivery_date": "20200319"
    },
    {
      "record_number": "61",
      "narcotic_use_licence_number": "62516",
      "narcotic_use_patient_address": "東京都世田谷区１−２３−４５−６７８",
      "narcotic_use_patient_tel": "03-1111-2222"
    },
    {
      "record_number": "101",
      "rp_number": "1",
      "dosage_form_class": "1",
      "dosage_form_name": null,
      "dispensing_quantity": "14"
    },
    {
      "record_number": "111",
      "rp_number": "1",
      "dosage_code_kind": "1",
      "dosage_code": null,
      "dosage_name": "1日3回 毎食後",
      "number_of_times_per_day": "3"
    },
    {
      "record_number": "201",
      "rp_number": "1",
      "rp_branch_number": "1",
      "information_class": null,
      "medication_code_kind": "7",
      "medication_code": "1149019F1ZZZ",
      "medication_name": "【般】ロキソプロフェンＮａ錠６０ｍｇ",
      "dose_quantity": "3",
      "strength_flag": "1",
      "unit_name": "錠"
    },
    {
      "record_number": "281",
      "rp_number": "1",
      "rp_branch_number": "1",
      "medication_branch_number": "1",
      "medication_supplement_class": null,
      "medication_supplement_information": "別包",
      "dosage_supplement_code": null
    },
    {
      "record_number": "201",
      "rp_number": "1",
      "rp_branch_number": "2",
      "information_class": null,
      "medication_code_kind": "3",
      "medication_code": "2329021F1021",
      "medication_name": "ムコスタ錠 １００ｍｇ",
      "dose_quantity": "3",
      "strength_flag": "1",
      "unit_name": "錠"
    },
    {
      "record_number": "281",
      "rp_number": "1",
      "rp_branch_number": "2",
      "medication_branch_number": "1",
      "medication_supplement_class": null,
      "medication_supplement_information": "別包",
      "dosage_supplement_code": null
    },
    {
      "record_number": "101",
      "rp_number": "2",
      "dosage_form_class": "1",
      "dosage_form_name": null,
      "dispensing_quantity": "14"
    },
    {
      "record_number": "111",
      "rp_number": "2",
      "dosage_code_kind": "1",
      "dosage_code": null,
      "dosage_name": "1日2回 朝・夕食後",
      "number_of_times_per_day": "2"
    },
    {
      "record_number": "201",
      "rp_number": "2",
      "rp_branch_number": "1",
      "information_class": null,
      "medication_code_kind": "3",
      "medication_code": "2171014G1020",
      "medication_name": "アダラートＬ錠 １０ｍｇ",
      "dose_quantity": "2",
      "strength_flag": "1",
      "unit_name": "錠"
    },
    {
      "record_number": "281",
      "rp_number": "2",
      "rp_branch_number": "1",
      "medication_branch_number": "1",
      "medication_supplement_class": "2",
      "medication_supplement_information": "粉砕",
      "dosage_supplement_code": null
    },
    {
      "record_number": "281",
      "rp_number": "2",
      "rp_branch_number": "1",
      "medication_branch_number": "2",
      "medication_supplement_class": "3",
      "medication_supplement_information": "後発品変更不可",
      "dosage_supplement_code": null
    },
    {
      "record_number": "101",
      "rp_number": "3",
      "dosage_form_class": "1",
      "dosage_form_name": null,
      "dispensing_quantity": "14"
    },
    {
      "record_number": "111",
      "rp_number": "3",
      "dosage_code_kind": "1",
      "dosage_code": null,
      "dosage_name": "1日1回 夕食後",
      "number_of_times_per_day": "1"
    },
    {
      "record_number": "201",
      "rp_number": "3",
      "rp_branch_number": "1",
      "information_class": null,
      "medication_code_kind": "3",
      "medication_code": "8114004G1027",
      "medication_name": "ＭＳコンチン錠 １０ｍｇ",
      "dose_quantity": "1",
      "strength_flag": "1",
      "unit_name": "錠"
    },
    {
      "record_number": "101",
      "rp_number": "4",
      "dosage_form_class": "3",
      "dosage_form_name": null,
      "dispensing_quantity": "1"
    },
    {
      "record_number": "111",
      "rp_number": "4",
      "dosage_code_kind": "1",
      "dosage_code": null,
      "dosage_name": "1日2回 貼付",
      "number_of_times_per_day": "0"
    },
    {
      "record_number": "201",
      "rp_number": "4",
      "rp_branch_number": "1",
      "information_class": null,
      "medication_code_kind": "3",
      "medication_code": "2649843S1039",
      "medication_name": "ＭＳ温シップ「タイホウ」２０ｇ（５枚／袋）",
      "dose_quantity": "3",
      "strength_flag": "1",
      "unit_name": "袋"
    },
    {
      "record_number": "101",
      "rp_number": "5",
      "dosage_form_class": "5",
      "dosage_form_name": null,
      "dispensing_quantity": "1"
    },
    {
      "record_number": "111",
      "rp_number": "5",
      "dosage_code_kind": "1",
      "dosage_code": null,
      "dosage_name": "1日3回 毎食前",
      "number_of_times_per_day": "0"
    },
    {
      "record_number": "201",
      "rp_number": "5",
      "rp_branch_number": "1",
      "information_class": null,
      "medication_code_kind": "3",
      "medication_code": "2492413G4040",
      "medication_name": "ノボリン２０Ｒ注フレックスペン",
      "dose_quantity": "1",
      "strength_flag": "1",
      "unit_name": "キット"
    },
    {
      "record_number": "101",
      "rp_number": "6",
      "dosage_form_class": "3",
      "dosage_form_name": null,
      "dispensing_quantity": "1"
    },
    {
      "record_number": "111",
      "rp_number": "6",
      "dosage_code_kind": "1",
      "dosage_code": null,
      "dosage_name": "1日3回 塗布",
      "number_of_times_per_day": "0"
    },
    {
      "record_number": "201",
      "rp_number": "6",
      "rp_branch_number": "1",
      "information_class": null,
      "medication_code_kind": "3",
      "medication_code": "7121703X1011",
      "medication_name": "白色ワセリン",
      "dose_quantity": "20",
      "strength_flag": "1",
      "unit_name": "g"
    },
    {
      "record_number": "201",
      "rp_number": "6",
      "rp_branch_number": "2",
      "information_class": null,
      "medication_code_kind": "7",
      "medication_code": null,
      "medication_name": "グリメサゾン軟膏",
      "dose_quantity": "30",
      "strength_flag": "1",
      "unit_name": "g"
    }
]