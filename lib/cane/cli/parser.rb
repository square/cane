require 'optparse'

require 'cane/default_checks'
require 'cane/cli/options'
require 'cane/version'

module Cane
  module CLI

    # Provides a specification for the command line interface that drives
    # documentation, parsing, and default values.
    class Parser

      # Exception to indicate that no further processing is required and the
      # program can exit. This is used to handle --help and --version flags.
      class OptionsHandled < RuntimeError; end

      def self.parse(*args)
        new.parse(*args)
      end

      def initialize(stdout = $stdout)
        @stdout = stdout

        add_banner
        add_user_defined_checks

        Cane.default_checks.each do |check|
          add_check_options(check)
        end
        add_checks_shortcut

        add_cane_options

        add_version
        add_help
      end

      def parse(args, ret = true)
        parser.parse!(get_default_options + args)

        Cane::CLI.default_options.merge(options)
      rescue OptionParser::InvalidOption, OptionParser::AmbiguousOption
        args = %w(--help)
        ret = false
        retry
      rescue OptionsHandled
        ret
      end

      def get_default_options
        read_options_from_file './.cane'
      end

      def read_options_from_file(file)
        if Cane::File.exists?(file)
          Cane::File.contents(file).split(/\s+/m)
        else
          []
        end
      end

      def add_banner
        parser.banner = <<-BANNER
Usage: cane [options]

Default options are loaded from a .cane file in the current directory.

BANNER
      end

      def add_user_defined_checks
        description = "Load a Ruby file containing user-defined checks"
        parser.on("-r", "--require FILE", description) do |f|
          load(f)
        end

        description = "Use the given user-defined check"
        parser.on("-c", "--check CLASS", description) do |c|
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

        add_option %w(--json),
          "Output as JSON", default: false

        add_option %w(--parallel),
          "Use all processors. Slower on small projects, faster on large.",
            cast: ->(x) { x }

        add_option %w(--color),
          "Colorize output", default: false

        parser.separator ""
      end

      def add_checks_shortcut
        description = "Apply all checks to given file"
        parser.on("-f", "--all FILE", description) do |f|
          # This is a bit of a hack, but provides a really useful UI for
          # dealing with single files. Let's see how it evolves.
          options[:abc_glob] = f
          options[:style_glob] = f
          options[:doc_glob] = f
        end
      end

      def add_version
        parser.on_tail("-v", "--version", "Show version") do
          stdout.puts Cane::VERSION
          raise OptionsHandled
        end
      end

      def add_help
        parser.on_tail("-h", "--help", "Show this message") do
          stdout.puts parser
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
          checks: Cane.default_checks
        }
      end

      def parser
        @parser ||= OptionParser.new
      end

      attr_reader :stdout
    end

  end
end
