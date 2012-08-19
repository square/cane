require 'cane/file'

# Configurable check that allows the contents of a file to be compared against
# a given value.
class ThresholdCheck < Struct.new(:checks)

  def self.key; :threshold; end

  def violations
    checks.map do |operator, file, limit|
      value = value_from_file(file)

      unless value.send(operator, limit.to_f)
        {
          description: 'Quality threshold crossed',
          label:       "%s is %s, should be %s %s" % [
            file, operator, value, limit
          ]
        }
      end
    end.compact
  end

  def value_from_file(file)
    begin
      contents = Cane::File.contents(file).chomp.to_f
    rescue Errno::ENOENT
      UnavailableValue.new
    end
  end

  # Null object for all cases when the value to be compared against cannot be
  # read.
  class UnavailableValue
    def >=(_); false end
    def to_s; 'unavailable' end
  end
end
