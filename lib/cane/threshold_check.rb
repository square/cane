require 'cane/file'

module Cane

  # Configurable check that allows the contents of a file to be compared against
  # a given value.
  class ThresholdCheck < Struct.new(:opts)

    def self.key; :threshold; end
    def self.options
      {
        gte: ["Check the number in FILE is >= to THRESHOLD " +
              "(a number or another file name)",
                variable: "FILE,THRESHOLD",
                type:     Array],
        eq:  ["Check the number in FILE is == to THRESHOLD " +
              "(a number or another file name)",
                variable: "FILE,THRESHOLD",
                type:     Array]
      }
    end

    def violations
      thresholds.map do |operator, file, threshold|
        value = normalized_limit(file)
        limit = normalized_limit(threshold)

        if !limit.real?
          {
            description: 'Quality threshold could not be read',
            label:       "%s is not a number or a file" % [
              threshold
            ]
          }
        elsif !value.send(operator, limit)
          {
            description: 'Quality threshold crossed',
            label:       "%s is %s, should be %s %s" % [
              file, value, operator, limit
            ]
          }
        end
      end.compact
    end

    def normalized_limit(limit)
      Float(limit)
    rescue ArgumentError
      value_from_file(limit)
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
      end +
      (opts[:eq] || []).map do |x|
        x.unshift(:==)
      end
    end

    # Null object for all cases when the value to be compared against cannot be
    # read.
    class UnavailableValue
      def >=(_); false end
      def to_s; 'unavailable' end
      def real?; false; end
    end
  end

end
