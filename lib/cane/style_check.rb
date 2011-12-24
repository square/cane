require 'tailor'
require 'tailor/file_line'

require 'cane/style_violation'

module Tailor
  class FileLine
    def print_problem(message)
      message = message.gsub(/\[.+\]\s+/, '')
      problems << StyleViolation.new(@file_path, @line_number, message)
    end

    def problems
      @problems ||= []
    end
  end
end

module Cane
  class StyleCheck < Struct.new(:opts)
    def violations
      @problem_count = 0
      Dir[opts.fetch(:files)].map do |file_name|
        find_violations_in_file(file_name)
      end.flatten
    end

    def find_violations_in_file(file_name)
      source    = File.open(file_name, 'r')
      file_path = Pathname.new(file_name)

      line_number = 1

      source.each_line.map do |source_line|
        line = Tailor::FileLine.new(source_line, file_path, line_number)

        @problem_count += line.spacing_problems

        # Check for camel-cased methods
        @problem_count += 1 if line.method_line? and line.camel_case_method?

        # Check for non-camel-cased classes
        @problem_count += 1 if line.class_line? and line.snake_case_class?

        # Check for long lines
        @problem_count += 1 if line.too_long?

        line_number += 1
        line.problems
      end
    end
  end
end
