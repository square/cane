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
      # the effects my monkey-patching FileLine above.
      spacing_problems
      method_line? && camel_case_method?
      class_line?  && snake_case_class?
      too_long?
    end

    # A copy of the parent method, except also strips text out of strings
    # quoted by "".
    def spacing_problems
      problem_count = 0

      # Disregard text in regexps
      self.gsub!(/\/.*?\//, "''")
      self.gsub!(/'.*?'/, "''")
      self.gsub!(/".*?"/, '""')

      SPACING_CONDITIONS.each_pair do |condition, values|
        unless self.scan(values.first).empty?
          problem_count += 1
          @line_problem_count += 1
          print_problem values[1]
        end
      end

      problem_count
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
