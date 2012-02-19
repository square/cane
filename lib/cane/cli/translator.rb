module Cane
  module CLI

    # Translates CLI options with given defaults to a hash suitable to be
    # passed to `Cane.run`.
    class Translator < Struct.new(:options, :defaults)
      def to_hash
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
        relevant_options = options.keys & params + [check]

        check == relevant_options[-1]
      end

      def option_with_default(key)
        options.fetch(key, defaults.fetch(key))
      end
    end

  end
end
