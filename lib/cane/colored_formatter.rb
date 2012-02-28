require 'term/ansicolor'
require 'cane/violation_formatter'

module Cane
  # Just a formatter, based on ViolationFormatter, for colored output
  # for the violations.
  class ColoredFormatter < ViolationFormatter
    include Term::ANSIColor
    INFINITY = (1/0.0)

    protected

    def format_group_header(description, violations)
      desc = [white, description, reset].join
      count = case violations.length
              when 0..5
                [yellow, violations.length.to_s, clear].join
              when 6..10
                [red, violations.length.to_s, clear].join
              when 11..INFINITY
                [bold, red, violations.length.to_s, clear].join
              end

      ["", "%s (%s):" % [desc, count], ""]
    end

    def format_violation(violation, widths)
      columns = violation.columns.map
      columns = columns.with_index do |column,i|
        "%-#{widths[i]}s" % parse(column)
      end

      ['  ' + columns.join('  ')]
    end

    private

    def parse(column)
      if column =~ /.*:\d+$/
        column = column.split(':')
        [yellow, column[0], clear, ':', column[1]].join
      else
        [red, column, clear].join
      end
    end
  end
end
