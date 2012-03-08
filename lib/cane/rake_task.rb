require 'rake'
require 'rake/tasklib'

module Cane
  # Creates a rake task to run cane with given configuration.
  #
  # Examples
  #
  #   desc "Run code quality checks"
  #   Cane::RakeTask.new(:quality) do |cane|
  #     cane.abc_max = 10
  #     cane.doc_glob = 'lib/**/*.rb'
  #     cane.add_threshold 'coverage/covered_percent', :>=, 99
  #   end
  class RakeTask < ::Rake::TaskLib
    attr_accessor :name

    # Glob to run ABC metrics over (default: "lib/**/*.rb")
    attr_accessor :abc_glob
    # Max complexity of methods to allow (default: 15)
    attr_accessor :abc_max
    # Glob to run style checks over (default: "{lib,spec}/**/*.rb")
    attr_accessor :style_glob
    # Max line length (default: 80)
    attr_accessor :style_measure
    # Glob to run doc checks over (default: "lib/**/*.rb")
    attr_accessor :doc_glob
    # Max violations to tolerate (default: 0)
    attr_accessor :max_violations

    # Add a threshold check. If the file exists and it contains a number,
    # compare that number with the given value using the operator.
    def add_threshold(file, operator, value)
      @threshold << [operator, file, value]
    end

    def initialize(task_name = nil)
      self.name = task_name || :cane
      @threshold = []
      yield self if block_given?

      unless ::Rake.application.last_comment
        desc %(Check code quality metrics with cane)
      end
      task name do
        require 'cane/cli'
        abort unless Cane.run(translated_options)
      end
    end

    def options
      [ :abc_glob, :abc_max,
        :style_glob, :style_measure,
        :doc_glob, :max_violations
      ].inject(:threshold => @threshold) do |opts, setting|
        value = self.send(setting)
        opts[setting] = value unless value.nil?
        opts
      end
    end

    def default_options
      Cane::CLI::Spec::DEFAULTS
    end

    def translated_options
      Cane::CLI::Translator.new(options, default_options).to_hash
    end
  end
end
