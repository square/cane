require 'optparse'

require 'cane/abc_check'
require 'cane/style_check'
require 'cane/doc_check'
require 'cane/threshold_check'

module Cane
  module CLI

    # Provides a specification for the command line interface that drives
    # documentation, parsing, and default values.
    class Spec
      CHECKS = [AbcCheck, StyleCheck, DocCheck, ThresholdCheck].freeze

      def self.defaults(check)
        x = check.options.each_with_object({}) {|(k, v), h|
          h[k] = (v[1] || {})[:default]
        }
        x
      end

      OPTIONS = {
        max_violations:  0,
        exclusions_file: nil,
      }.merge(CHECKS.inject({}) {|a, check| a.merge(defaults(check)) })

      # Exception to indicate that no further processing is required and the
      # program can exit. This is used to handle --help and --version flags.
      class OptionsHandled < RuntimeError; end

      def initialize
        add_banner
        add_custom_checks

        CHECKS.each do |check|
          add_check_options(check)
        end

        add_cane_options

        add_version
        add_help
      end

      def parse(args, ret = true)
        parser.parse!(get_default_options + args)

        OPTIONS.merge(options)
      rescue OptionParser::InvalidOption
        args = %w(--help)
        ret = false
        retry
      rescue OptionsHandled
        ret
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

      def add_custom_checks
        description = "Load a Ruby file containing custom checks"
        parser.on("-r", "--require FILE", description) do |f|
          load(f)
        end

        parser.on("-c", "--check CLASS", "Use the given check") do |c|
          # TODO: Validate check
          check = Kernel.const_get(c)
          options[:checks] << check
          add_check_options(check)
        end
        parser.separator ""
      end

      def add_check_options(check)
        check.options.each do |key, data|
          cli_key  = key.to_s.tr('_', '-')
          opts     = data[1] || {}
          variable = opts[:variable] || "VALUE"
          defaults = opts[:default] || []

          if opts[:type] == Array
            parser.on("--#{cli_key} #{variable}", Array, data[0]) do |opts|
              (options[key.to_sym] ||= []) << opts
            end
          else
            if [*defaults].length > 0
              add_option ["--#{cli_key}", variable], *data
            else
              add_option ["--#{cli_key}"], *data
            end
          end
        end

        parser.separator ""
      end

      def add_cane_options
        add_option %w(--max-violations VALUE),
          "Max allowed violations", default: 0, cast: :to_i

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

      def add_option(option, description, opts={})
        option_key = option[0].gsub('--', '').tr('-', '_').to_sym
        default    = opts[:default]
        cast       = opts[:cast] || ->(x) { x }

        if default
          description += " (default: %s)" % default
        end

        parser.on(option.join(' '), description) do |v|
          options[option_key] = cast.to_proc.call(v)
          options.delete(opts[:clobber])
        end
      end

      def options
        @options ||= {
          checks: CHECKS.dup
        }
      end

      def parser
        @parser ||= OptionParser.new
      end
    end

  end
end
