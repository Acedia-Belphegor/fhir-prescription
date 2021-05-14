module JamiUsages

  # 基本用法区分
  USAGE_BASE_CODE = {
    "1"=>"内服",
    "2"=>"外用"
  }

  # 用法詳細区分
  USAGE_DETAIL_CODE = {
    "0"=>"経口",
    "1"=>"舌下",
    "2"=>"バッカル（歯茎と頬の間に挟む）",
    "3"=>"口腔内塗布",
    "A"=>"貼付",
    "B"=>"塗布",
    "C"=>"湿布",
    "D"=>"撒布",
    "E"=>"噴霧",
    "F"=>"消毒",
    "G"=>"点耳",
    "H"=>"点眼",
    "J"=>"点鼻",
    "K"=>"うがい",
    "L"=>"吸入",
    "M"=>"トローチ",
    "N"=>"膀胱洗浄",
    "P"=>"鼻腔内洗浄",
    "Q"=>"浣腸",
    "R"=>"肛門挿入",
    "S"=>"肛門注入",
    "T"=>"膣内挿入",
    "U"=>"膀胱注入",
  }.freeze
  
  def get_method_as_codeable_concept(usage_code)
    code = usage_code.slice(0, 1) # 基本用法区分
    create_codeable_concept code, USAGE_BASE_CODE[code], "urn:oid:1.2.392.100495.20.2.34"
  end

  def get_route_as_codeable_concept(usage_code)
    code = usage_code.slice(1, 1) # 用法詳細区分
    create_codeable_concept code, USAGE_DETAIL_CODE[code], "urn:oid:1.2.392.100495.20.2.35"
  end

  module_function :get_method_as_codeable_concept
  module_function :get_route_as_codeable_concept
end