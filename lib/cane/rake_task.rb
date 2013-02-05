require 'rake'
require 'rake/tasklib'

require 'cane/cli/options'
require 'cane/cli/parser'

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
    attr_reader :options

    Cane::CLI.default_options.keys.each do |name|
      define_method(name) do
        options.fetch(name)
      end

      define_method("#{name}=") do |v|
        options[name] = v
      end
    end

    # Add a threshold check. If the file exists and it contains a number,
    # compare that number with the given value using the operator.
    def add_threshold(file, operator, value)
      if operator == :>=
        @options[:gte] << [file, value]
      end
    end

    def use(check, options = {})
      @options.merge!(options)
      @options[:checks] = @options[:checks] + [check]
    end

    def canefile=(file)
      canefile = Cane::CLI::Parser.new
      canefile.parser.parse!(canefile.read_options_from_file(file))
      options.merge! canefile.options
    end

    def initialize(task_name = nil)
      self.name = task_name || :cane
      @gte = []
      @options = Cane::CLI.default_options

      if block_given?
        yield self
      else
        self.canefile = './.cane'
      end

      unless ::Rake.application.last_comment
        desc %(Check code quality metrics with cane)
      end

      task name do
        require 'cane/cli'
        abort unless Cane.run(options)
      end
    end
  end
end
