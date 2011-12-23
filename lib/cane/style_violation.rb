class StyleViolation < Struct.new(:file_name, :line, :message)
  def self.description
    "Lines violated style requirements"
  end

  def columns
    ["%s:%i" % [file_name, line], message]
  end
end
