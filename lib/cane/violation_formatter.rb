require 'stringio'

module Cane
  class ViolationFormatter < Struct.new(:violations)
    def to_s
      return '' if violations.empty?

      grouped_violations.map do |description, violations|
        format_group_header(description, violations) +
          format_violations(violations)
      end.flatten.join("\n") + "\n\n"
    end

    protected

    def format_group_header(description, violations)
      ["", "%s (%i):" % [description, violations.length], ""]
    end

    def format_violations(violations)
      column_widths = calculate_columm_widths(violations)

      violations.map do |violation|
        format_violation(violation, column_widths)
      end
    end

    def format_violation(violation, column_widths)
      [
        '  ' + violation.columns.map.with_index { |column, index|
          "%-#{column_widths[index]}s" % column
        }.join('  ')
      ]
    end

    def calculate_columm_widths(violations)
      violations.map { |violation|
        violation.columns.map { |x| x.to_s.length }
      }.transpose.map(&:max)
    end

    def grouped_violations
      violations.group_by(&:description)
    end
  end
end
