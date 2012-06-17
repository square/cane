require 'optparse'
require 'cane/cli/translator'

module Cane
  module CLI

    # Provides a specification for the command line interface that drives
    # documentation, parsing, and default values.
    class Spec
      DEFAULTS = {
        abc_glob:       '{app,lib}/**/*.rb',
        abc_max:        '15',
        style_glob:     '{app,lib,spec}/**/*.rb',
        style_measure:  '80',
        doc_glob:       '{app,lib}/**/*.rb',
        encoding_glob:  '{app,lib}/**/*.rb',
        max_violations: '0',
      }

      # Exception to indicate that no further processing is required and the
      # program can exit. This is used to handle --help and --version flags.
      class OptionsHandled < RuntimeError; end

      def initialize
        add_banner

        add_abc_options
        add_style_options
        add_doc_options
        add_encoding_options
        add_threshold_options
        add_cane_options

        add_version
        add_help
      end

      def parse(args)
        parser.parse!(get_default_options + args)

        Translator.new(options, DEFAULTS).to_hash
      rescue OptionsHandled
        nil
      end

      def get_default_options
        if File.exists?('./.cane')
          File.read('./.cane').gsub("\n", ' ').split(' ')
        else
          []
        end
      end

      def add_banner
        parser.banner = <<-BANNER
Usage: cane [options]

You can also put these options in a .cane file.

BANNER
      end

      def add_abc_options
        add_option %w(--abc-glob GLOB), "Glob to run ABC metrics over"
        add_option %w(--abc-max VALUE), "Ignore methods under this complexity"
        add_option %w(--no-abc), "Disable ABC checking"

        parser.separator ""
      end

      def add_encoding_options
        add_option %w(--encoding-glob GLOB), "Glob to run encoding metrics over"
        add_option %w(--no-encoding), "Disable Encoding checking"

        parser.separator ""
      end

      def add_style_options
        add_option %w(--style-glob GLOB), "Glob to run style metrics over"
        add_option %w(--style-measure VALUE), "Max line length"
        add_option %w(--no-style), "Disable style checking"

        parser.separator ""
      end

      def add_doc_options
        add_option %w(--doc-glob GLOB), "Glob to run documentation checks over"
        add_option %w(--no-doc), "Disable documentation checking"

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
        add_option %w(--max-violations VALUE), "Max allowed violations"

        parser.separator ""
      end

      def add_version
        parser.on_tail("--version", "Show version") do
          puts Cane::VERSION
          raise OptionsHandled
        end
      end

      def add_help
        parser.on_tail("-h", "--help", "Show this message") do
          puts parser
          raise OptionsHandled
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

      def options
        @options ||= {}
      end

      def parser
        @parser ||= OptionParser.new
      end
    end

  end
end
