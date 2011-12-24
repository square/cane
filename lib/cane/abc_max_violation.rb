class AbcMaxViolation < Struct.new(:file_name, :detail, :complexity)
  def columns
    [file_name, detail, complexity]
  end

  def self.description
    "Methods exceeded maximum allowed ABC complexity"
  end
end
