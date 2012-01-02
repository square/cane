require 'cane/cli/translator'

module Cane
  module CLI

    # Provides a specification for the command line interface that drives
    # documentation, parsing, and default values.
    class Spec
      DEFAULTS = {
        abc_glob:       'lib/**/*.rb',
        abc_max:        '15',
        style_glob:     '{lib,spec}/**/*.rb',
        style_measure:  '80',
        doc_glob:       'lib/**/*.rb',
        max_violations: '0',
      }

      def initialize
        add_abc_options
        add_style_options
        add_doc_options
        add_threshold_options
        add_cane_options

        add_version
        add_help
      end

      def parse(args)
        parser.parse!(args)
        Translator.new(options, DEFAULTS).to_hash
      end

      def add_abc_options
        add_option(%w(--abc-glob GLOB), "Glob to run ABC metrics over")
        add_option(%w(--abc-max VALUE), "Ignore methods under this complexity")
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
        add_option(%w(--doc-glob GLOB), "Glob to run doc checks over")
        add_option(%w(--no-doc), "Disable documentation checking")

        parser.separator ""
      end

      def add_threshold_options
        desc = "If FILE contains a number, verify it is >= to THRESHOLD."
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

      def parser
        @parser ||= OptionParser.new
      end
    end

  end
end
