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
      CHECKS = [AbcCheck, StyleCheck, DocCheck, ThresholdCheck]

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

        CHECKS.each do |check|
          add_check_options(check)
        end

        add_cane_options

        add_version
        add_help
      end

      def parse(args)
        parser.parse!(get_default_options + args)

        OPTIONS.merge(options)
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

      def add_check_options(check)
        check.options.each do |key, data|
          key      = key.to_s.tr('_', '-')
          opts     = data[1] || {}
          variable = opts[:variable] || "VALUE"
          defaults = opts[:default] || []

          if opts[:type] == Array
            parser.on("--#{key} #{variable}", Array, data[0]) do |opts|
              (options[key.to_sym] ||= []) << opts
            end
          else
            if [*defaults].length > 0
              add_option ["--#{key}", variable], *data
            else
              add_option ["--#{key}"], *data
            end
          end
        end

        parser.separator ""
      end

      def add_cane_options
        add_option %w(--max-violations VALUE),
          "Max allowed violations", default: 0, cast: :to_i

        desc = "YAML file containing a list of exclusions"

        # TODO: Combine this with .cane file, use normal options
        parser.on(%w(--exclusions-file FILE).join(' '), desc) do |file|
          exclusions = YAML.load_file(file)
          options[:abc_exclusions]   = exclusions['abc']   || []
          options[:style_exclusions] = exclusions['style'] || []
        end

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
        @options ||= {}
      end

      def parser
        @parser ||= OptionParser.new
      end
    end

  end
end
