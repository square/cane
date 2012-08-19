require 'optparse'
require 'cane/cli/translator'

require 'cane/abc_check'
require 'cane/style_check'
require 'cane/doc_check'
require 'cane/threshold_check'

module Cane
  module CLI

    # Provides a specification for the command line interface that drives
    # documentation, parsing, and default values.
    class Spec
      CHECKS = [AbcCheck, StyleCheck, DocCheck, ThresholdCheck]
      SIMPLE_CHECKS = CHECKS - [ThresholdCheck]

      def self.defaults(check)
        check.options.each_with_object({}) {|(k, v), h|
          h[("%s_%s" % [check.key, k]).to_sym] = v[1]
        }
      end

      DEFAULTS = {
        max_violations: '0',
      }.merge(SIMPLE_CHECKS.inject({}) {|a, check| a.merge(defaults(check)) })

      # Exception to indicate that no further processing is required and the
      # program can exit. This is used to handle --help and --version flags.
      class OptionsHandled < RuntimeError; end

      def initialize
        add_banner

        SIMPLE_CHECKS.each do |check|
          add_check_options(check)
        end

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
        if ::File.exists?('./.cane')
          ::File.read('./.cane').gsub("\n", ' ').split(' ')
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

      def add_threshold_options
        desc = "If FILE contains a number, verify it is >= to THRESHOLD."
        parser.on("--gte FILE,THRESHOLD", Array, desc) do |opts|
          (options[:threshold] ||= []) << opts.unshift(:>=)
        end

        parser.separator ""
      end

      def add_check_options(check)
        check.options.each do |key, data|
          add_option ["--#{check.key}-#{key}", "VALUE"], data[0]
        end
        add_option ["--no-#{check.key}"], "Disable #{check.name}"

        parser.separator ""
      end

      def add_cane_options
        add_option %w(--max-violations VALUE), "Max allowed violations"
        add_option %w(--exclusions-file FILE),
                   "YAML file containing a list of exclusions"

        parser.separator ""
      end

      def add_version
        parser.on_tail("-v", "--version", "Show version") do
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
