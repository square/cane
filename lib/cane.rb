require 'cane/abc_check'
require 'cane/style_check'
require 'cane/doc_check'
require 'cane/threshold_check'
require 'cane/colored_formatter'
require 'cane/violation_formatter'

module Cane
  def run(opts)
    Runner.new(opts).run
  end
  module_function :run

  # Orchestrates the running of checks per the provided configuration, and
  # hands the result to a formatter for display. This is the core of the
  # application, but for the actual entry point see `Cane::CLI`.
  class Runner
    CHECKERS = {
      abc:       AbcCheck,
      style:     StyleCheck,
      doc:       DocCheck,
      threshold: ThresholdCheck
    }

    def initialize(opts)
      @opts = opts
    end

    def run
      klass = @opts[:output][:color] ? ColoredFormatter : ViolationFormatter
      outputter.print klass.new(violations)

      violations.length <= opts.fetch(:max_violations)
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
