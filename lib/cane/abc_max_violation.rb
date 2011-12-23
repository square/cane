class AbcMaxViolation < Struct.new(:file_name, :detail, :line)
  def columns
    [file_name, detail, line]
  end

  def self.description
    "Methods exceeded maximum allowed ABC complexity"
  end
end
