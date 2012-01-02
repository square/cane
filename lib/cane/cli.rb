require 'cane'
require 'cane/version'

module Cane
  class CLI < Struct.new(:args)
    DEFAULTS = {
      abc_glob:       'lib/**/*.rb',
      abc_max:        '15',
      style_glob:     '{lib,spec}/**/*.rb',
      style_measure:  '80',
      doc_glob:       'lib/**/*.rb',
      max_violations: '0',
    }

    def self.run(args)
      new(args).run
    end

    def run
      add_abc_options
      add_style_options
      add_doc_options
      add_threshold_options
      add_cane_options

      add_version
      add_help

      parser.parse!(args)

      Cane.run(translate_options)
    end

    def add_abc_options
      add_option(%w(--abc-glob GLOB), "Glob to run ABC metrics over")
      add_option(%w(--abc-max VALUE),
                 "Report any methods with complexity greater than VALUE")
      add_option(%w(--no-abc), "Disable ABC checking")

      parser.separator ""
    end

    def add_style_options
      add_option(%w(--style-glob GLOB), "Glob to run style metrics over")
      add_option(%w(--style-measure VALUE), "Max line length")
      add_option(%w(--no-style), "Disable style checking")

      parser.separator ""
    end

    def add_doc_options
      add_option(%w(--doc-glob GLOB), "Glob to run documentation metrics over")
      add_option(%w(--no-doc), "Disable documentation checking")

      parser.separator ""
    end

    def add_threshold_options
      desc = "If FILE contains a single number, verify it is >= to THRESHOLD."
      parser.on("--gte FILE,THRESHOLD", Array, desc) do |opts|
        (options[:threshold] ||= []) << opts.unshift(:>=)
      end

      parser.separator ""
    end

    def add_cane_options
      add_option(%w(--max-violations VALUE), "Max allowed violations")

      parser.separator ""
    end

    def add_version
      # Another typical switch to print the version.
      parser.on_tail("--version", "Show version") do
        puts Cane::VERSION
        exit
      end
    end

    def add_help
      parser.on_tail("-h", "--help", "Show this message") do
        puts parser
        exit
      end
    end

    def translate_options
      result = {}
      translate_abc_options(result)
      translate_doc_options(result)
      translate_style_options(result)

      result[:threshold] = options.fetch(:threshold, [])
      result[:max_violations] = option_with_default(:max_violations).to_i

      result
    end

    def translate_abc_options(result)
      result[:abc] = {
        files: option_with_default(:abc_glob),
        max:   option_with_default(:abc_max).to_i
      } unless check_disabled(:no_abc, [:abc_glob, :abc_max])
    end

    def translate_style_options(result)
      result[:style] = {
        files:   option_with_default(:style_glob),
        measure: option_with_default(:style_measure).to_i,
      } unless check_disabled(:no_style, [:style_glob])
    end

    def translate_doc_options(result)
      result[:doc] = {
        files: option_with_default(:doc_glob),
      } unless check_disabled(:no_doc, [:doc_glob])
    end

    def check_disabled(check, params)
      ((params + [check]) & options.keys) == [check]
    end

    def add_option(option, description)
      option_key = option[0].gsub('--', '').tr('-', '_').to_sym

      if DEFAULTS.has_key?(option_key)
        description += " (default: %s)" % DEFAULTS[option_key]
      end

      parser.on(option.join(' '), description) do |v|
        options[option_key] = v
      end
    end

    def default(message, default_value)
      "%s (default: %s)" % [message, default_value]
    end

    def options
      @options ||= {}
    end

    def option_with_default(key)
      options.fetch(key, DEFAULTS.fetch(key))
    end

    def parser
      @parser ||= OptionParser.new
    end
  end
end
