require 'stringio'

module Cane
  class ViolationFormatter < Struct.new(:violations)
    def to_s
      return '' if violations.empty?

      build_string do |out|
        violations.group_by(&:class).each do |klass, violations|
          output_group_header(klass, out)

          column_widths = calculate_columm_widths(violations)

          violations.each do |v|
            output_violation(v, column_widths, out)
          end
        end
        out.puts
      end
    end

    protected

    def build_string
      out = StringIO.new(buffer = "")
      yield out
      buffer
    end

    def calculate_columm_widths(violations)
      violations.map do |v|
        v.columns.map { |x| x.to_s.length }
      end.transpose.map(&:max)
    end

    def output_violation(v, column_widths, out)
      out.print('  ')
      v.columns.each.with_index do |c, i|
        out.print("%-#{column_widths[i] + 2}s" % c)
      end
      out.puts
    end

    def output_group_header(klass, out)
      out.puts
      out.puts klass.description + ":"
      out.puts
    end
  end
end
