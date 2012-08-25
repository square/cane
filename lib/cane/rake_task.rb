require 'rake'
require 'rake/tasklib'

require 'cane/cli/spec'

module Cane
  # Creates a rake task to run cane with given configuration.
  #
  # Examples
  #
  #   desc "Run code quality checks"
  #   Cane::RakeTask.new(:quality) do |cane|
  #     cane.abc_max = 10
  #     cane.doc_glob = 'lib/**/*.rb'
  #     cane.no_style = true
  #     cane.add_threshold 'coverage/covered_percent', :>=, 99
  #   end
  class RakeTask < ::Rake::TaskLib
    attr_accessor :name
    OPTIONS = Cane::CLI::Spec::OPTIONS
    OPTIONS.each do |name, value|
      attr_accessor name
    end

    # Add a threshold check. If the file exists and it contains a number,
    # compare that number with the given value using the operator.
    def add_threshold(file, operator, value)
      if operator == :>=
        @gte << [file, value]
      end
    end

    def use(check, options = {})
      @checks << check
      @options.merge!(options)
    end

    def initialize(task_name = nil)
      self.name = task_name || :cane
      @gte = []
      @checks = Cane::DEFAULT_CHECKS.dup
      @options = {}

      yield self if block_given?

      unless ::Rake.application.last_comment
        desc %(Check code quality metrics with cane)
      end

      task name do
        require 'cane/cli'
        abort unless Cane.run(
          OPTIONS.
            merge(options).
            merge(checks: @checks).
            merge(@options)
        )
      end
    end

    def options
      OPTIONS.keys.inject({}) do |opts, setting|
        value = self.send(setting)
        opts[setting] = value unless value.nil?
        opts
      end
    end
  end
end
