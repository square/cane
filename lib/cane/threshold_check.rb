require 'cane/threshold_violation'

class ThresholdCheck < Struct.new(:checks)
  def violations
    checks.map do |operator, file, limit|
      value = value_from_file(file)

      unless value.send(operator, limit.to_f)
        ThresholdViolation.new(file, operator, value, limit)
      end
    end.compact
  end

  def value_from_file(file)
    begin
      contents = File.read(file).chomp.to_f
    rescue Errno::ENOENT
      UnavailableValue.new
    end
  end

  class UnavailableValue
    def >=(_); false end
    def to_s; 'unavailable' end
  end
end
