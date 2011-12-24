require 'cane/abc_check'
require 'cane/style_check'
require 'cane/threshold_check'
require 'cane/violation_formatter'

module Cane
  def run(opts)
    Runner.new(opts).run
  end
  module_function :run

  class Runner
    CHECKERS = {
      abc:       AbcCheck,
      style:     StyleCheck,
      threshold: ThresholdCheck
    }

    def initialize(opts)
      @opts = opts
    end

    def run
      outputter.print ViolationFormatter.new(violations)

      violations.length == 0
    end

    protected

    attr_reader :opts

    def violations
      @violations ||= CHECKERS.
        select { |key, _| opts.has_key?(key) }.
        map { |key, check| check.new(opts.fetch(key)).violations }.
        flatten
    end

    def outputter
      opts.fetch(:out, $stdout)
    end
  end
end
