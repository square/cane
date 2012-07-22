module Cane

  # Creates violations for ruby files that have no encoding marker in the
  # first two lines
  class EncodingCheck < Struct.new(:opts)
    def violations
      file_names.map { |file_name|
        find_violations(file_name)
      }.flatten.compact
    end

    def find_violations(file_name)
      data = File.open(file_name, 'r:utf-8')
      line_one, line_two = *data.lines

      if !line_one.to_s.match(/coding:/) && !line_two.to_s.match(/coding:/)
        NoEncodingViolation.new(file_name)
      end
    end

    def file_names
      Dir[opts.fetch(:files)]
    end

  end

  # Value object used by EncodingCheck
  class NoEncodingViolation < Struct.new(:file_name)
    def description
      "Source file missing an encoding marker"
    end

    def columns
      [file_name]
    end

  end

end
