module Cane

  # Provides iteration over lines (from a file), correctly handling encoding.
  class EncodingAwareIterator
    include Enumerable

    def initialize(lines)
      @lines = lines
    end

    def each(&block)
      return self.to_enum unless block

      lines.each do |line|
        begin
          line =~ /\s/
        rescue ArgumentError
          line.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace)
        end

        block.call(line)
      end
    end

    protected

    attr_reader :lines
  end

end
