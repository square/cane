# Value object used by StyleCheck.
class StyleViolation < Struct.new(:file_name, :line, :message)
  def description
    "Lines violated style requirements"
  end

  def columns
    ["%s:%i" % [file_name, line], message]
  end
end
