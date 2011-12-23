require 'stringio'

module Cane
  class ViolationFormatter < Struct.new(:violations)
    def to_s
      out = StringIO.new(buffer = "")
      violations.group_by(&:class).each do |klass, violations|
        out.puts
        out.puts klass.description + ":"
        out.puts

        column_widths = violations.map do |v|
          v.columns.map {|x| x.to_s.length }
        end.transpose.map(&:max)

        violations.each do |v|
          out.print('  ')
          v.columns.each.with_index do |c, i|
            out.print("%-#{column_widths[i] + 2}s" % c)
          end
          out.puts
        end
      end
      out.puts
      buffer
    end
  end
end
