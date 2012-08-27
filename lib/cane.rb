require 'parallel'

require 'cane/violation_formatter'

module Cane
  def run(*args)
    Runner.new(*args).run
  end
  module_function :run

  def task_runner(opts)
    if opts[:parallel]
      Parallel
    else
      SimpleTaskRunner
    end
  end
  module_function :task_runner

  # Mirrors the Parallel gem's interface but does not provide any parralleism.
  # This is faster for smaller tasks since it doesn't incur any overhead for
  # creating new processes and communicating between them.
  class SimpleTaskRunner
    def self.map(enumerable, &block)
      enumerable.map(&block)
    end
  end

  # Orchestrates the running of checks per the provided configuration, and
  # hands the result to a formatter for display. This is the core of the
  # application, but for the actual entry point see `Cane::CLI`.
  class Runner
    def initialize(spec)
      @opts = spec
      @checks = spec[:checks]
    end

    def run
      outputter.print ViolationFormatter.new(violations)

      violations.length <= opts.fetch(:max_violations)
    end

    protected

    attr_reader :opts, :checks

    def violations
      @violations ||= checks.
        map {|check| check.new(opts).violations }.
        flatten
    end

    def outputter
      opts.fetch(:out, $stdout)
    end
  end
end
