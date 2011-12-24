require 'cane/threshold_violation'

class ThresholdCheck < Struct.new(:checks)
  def violations
    checks.map do |check|
      operator, file, limit = *check

      value = File.read(file).chomp
      unless value.to_f.send(operator, limit.to_f)
        ThresholdViolation.new(file, operator, value, limit)
      end
    end.compact
  end
end
