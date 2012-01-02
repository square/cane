require 'tailor'

require 'cane/style_violation'

module Cane
  # Provide a wrapper around Tailor that has an interface matching what we want
  class FileLine < Tailor::FileLine
    def initialize(source_line)
      super(source_line, nil, nil)
    end

    def print_problem(message)
      @problems << message.gsub(/\[.+\]\s+/, '')
    end

    def problems
      @problems = []
      find_problems
      @problems
    end

    def find_problems
      # This is weird. These methods actually have side-effects! We capture
      # the effects my monkey-patching #print_problem above.
      spacing_problems
      method_line? && camel_case_method?
      class_line?  && snake_case_class?
      too_long?
    end

    # A copy of the parent method that only uses a small subset of the spacing
    # checks we actually want (the others are too buggy or controversial).
    def spacing_problems
      spacing_conditions.each_pair do |condition, values|
        unless self.scan(values.first).empty?
          print_problem values[1]
        end
      end
    end

    def spacing_conditions
      SPACING_CONDITIONS.select {|k, _|
        [:hard_tabbed, :trailing_whitespace].include?(k)
      }
    end
  end

  class StyleCheck < Struct.new(:opts)
    def violations
      Dir[opts.fetch(:files)].map do |file_name|
        find_violations_in_file(file_name)
      end.flatten
    end

    protected

    def find_violations_in_file(file_name)
      source    = File.open(file_name, 'r')
      file_path = Pathname.new(file_name)

      source.each_line.map.with_index do |source_line, line_number|
        violations_for_line(file_path, source_line, line_number)
      end
    end

    def violations_for_line(file_path, source_line, line_number)
      FileLine.new(source_line).problems.map do |message|
        StyleViolation.new(file_path, line_number + 1, message)
      end
    end
  end
end
