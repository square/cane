module Cane

  # Value object used by AbcCheck for a file that cannot be parsed. This is
  # handled by AbcCheck rather than a separate class since it is a low value
  # violation (syntax errors should have been picked up by specs) but we still
  # have to deal with the edge case.
  class SyntaxViolation < Struct.new(:file_name)
    def columns
      [file_name]
    end

    def description
      "Files contained invalid syntax"
    end

    def sort_index
      0
    end
  end
end
