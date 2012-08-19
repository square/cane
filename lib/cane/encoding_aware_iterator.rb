module Cane

  # Provides iteration over lines (from a file), correctly handling encoding.
  class EncodingAwareIterator < Struct.new(:lines)
    def map_with_index(&block)
      lines.map.with_index do |line, index|
        with_encoding_retry(line) do
          block.call(line, index)
        end
      end
    end

    protected

    # This is to avoid re-encoding every line, since most are valid. I should
    # performance test this but haven't (maybe can just re-encode always but my
    # hunch says no).
    def with_encoding_retry(line, &block)
      retried = false
      begin
        block.call(line)
      rescue ArgumentError
        if retried
          # I haven't seen input that causes this to occur. Please report it!
          raise
        else
          line.encode!('UTF-8', 'UTF-8', invalid: :replace)
          retried = true
          retry
        end
      end
    end
  end

end
