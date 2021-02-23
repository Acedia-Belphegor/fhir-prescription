class String
  def numeric?
    nil != (self =~ /\A[0-9.]+\z/)
  end

  def to_numeric
    if numeric?
      include?(".") ? to_f : to_i # 小数点が含まれている場合はFloatで返す
    else
      0
    end
  end
end

class Float
  def integer?
    self == self.to_i
  end
end