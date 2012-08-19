require 'stringio'
require 'ostruct'

module Cane

  # Computes a string to be displayed as output from an array of violations
  # computed by the checks.
  class ViolationFormatter
    attr_reader :violations

    def initialize(violations)
      @violations = violations.map do |v|
        v.merge(file_and_line: v[:line] ?
          "%s:%i" % v.values_at(:file, :line) :
          v[:file]
        )
      end
    end

    def to_s
      return "" if violations.empty?

      violations.group_by {|x| x[:description] }.map do |d, vs|
        format_group_header(d, vs) +
          format_violations(vs)
      end.join("\n") + "\n\n" + totals + "\n\n"
    end

    protected

    def format_group_header(description, violations)
      ["", "%s (%i):" % [description, violations.length], ""]
    end

    def format_violations(violations)
      columns = [:file_and_line, :label, :value]

      widths = column_widths(violations, columns)

      violations.map do |v|
        format_violation(v, widths)
      end
    end

    def column_widths(violations, columns)
      columns.each_with_object({}) do |column, h|
        h[column] = violations.map {|v| v[column].to_s.length }.max
      end
    end

    def format_violation(v, column_widths)
      '  ' + column_widths.keys.map {|column|
        v[column].to_s.ljust(column_widths[column])
      }.join('  ').strip
    end

    def totals
      "Total Violations: #{violations.length}"
    end
  end
end
