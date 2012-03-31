module Cane

  # Value object used by AbcCheck for a method that is too complicated.
  class AbcMaxViolation < Struct.new(:file_name, :detail, :complexity)
    def columns
      [file_name, detail, complexity]
    end

    def description
      "Methods exceeded maximum allowed ABC complexity"
    end

    alias_method :sort_index, :complexity
  end
end
