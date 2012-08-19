require 'yaml'

module Cane
  module CLI

    # Translates CLI options with given defaults to a hash suitable to be
    # passed to `Cane.run`.
    class Translator < Struct.new(:options, :defaults, :checks)
      def to_hash
        result = {}
        checks.each do |check|
          translate_options(result, check)
        end

        result[:threshold] = options.fetch(:threshold, [])
        result[:max_violations] =
          options.fetch(:max_violations, defaults[:max_violations]).to_i

        result
      end

      def translate_options(result, check)
        unless check_disabled(check)
          result[check.key] = {
            exclusions: exclusions_for(check.key)
          }.merge(extract_options(check))
        end
      end

      def extract_options(check)
        check.options.each_with_object({}) do |(k, v), h|
          h[k] = cast_for(v).call(options.fetch(to_cli_key(check, k), v[1]))
        end
      end

    private

      def check_disabled(check)
        disable_key = :"no_#{check.key}"
        params = check.options.keys.map {|x| to_cli_key(check, x) }

        relevant_options = options.keys & params + [disable_key]

        disable_key == relevant_options[-1]
      end

      def cast_for(v)
        (v[2] || ->(x){ x }).to_proc
      end

      def to_cli_key(check, k)
        :"#{check.key}_#{k}"
      end

      def exclusions_for(tool)
        Array(exclusions[tool.to_s])
      end

      def exclusions
        @exclusions ||= if file = options[:exclusions_file]
          YAML.load_file(file)
        else
          {}
        end
      end
    end

  end
end
