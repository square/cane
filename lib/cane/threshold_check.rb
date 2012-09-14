require 'cane/file'

module Cane

  # Configurable check that allows the contents of a file to be compared against
  # a given value.
  class ThresholdCheck < Struct.new(:opts)

    def self.key; :threshold; end
    def self.options
      {
        gte: ["If FILE contains a number, verify it is >= to THRESHOLD",
                variable: "FILE,THRESHOLD",
                type:     Array]
      }
    end

    def violations
      thresholds.map do |operator, file, limit|
        value = value_from_file(file)

        if limit.to_f != limit
          if Cane::File.exists?(limit)
            limit = value_from_file(limit)
          else
            limit = UnavailableValue.new
          end
        end

        unless value.send(operator, limit.to_f)
          {
            description: 'Quality threshold crossed',
            label:       "%s is %s, should be %s %s" % [
              file, value, operator, limit
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

    def thresholds
      (opts[:gte] || []).map do |x|
        x.unshift(:>=)
      end
    end

    # Null object for all cases when the value to be compared against cannot be
    # read.
    class UnavailableValue
      def >=(_); false end
      def to_s; 'unavailable' end
    end
  end

end
