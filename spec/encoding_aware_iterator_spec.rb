# encoding: utf-8
require 'xspec_helper'

require 'cane/encoding_aware_iterator'

# Example bad input from:
#   http://stackoverflow.com/questions/1301402/example-invalid-utf8-string
describe Cane::EncodingAwareIterator do
  it 'handles non-UTF8 input' do
    lines    = ["\xc3\x28"]
    iterator = Cane::EncodingAwareIterator.new(lines)
    result   = iterator.map.with_index do |line, number|
      assert line.is_a?(String)
      [line =~ /\s/, number]
    end
    assert_equal [[nil, 0]], result
  end

  it 'does not enter an infinite loop on persistently bad input' do
    begin
      iterator = Cane::EncodingAwareIterator.new([""])
      iterator.map.with_index do |line, number|
        "\xc3\x28" =~ /\s/
      end
      fail "no error raised"
    rescue ArgumentError
      assert true
    end
  end

  it 'allows each with no block' do
    called_with_line = nil
    Cane::EncodingAwareIterator.new([""]).each.with_index do |line, number|
      called_with_line = line
    end
    assert_equal "", called_with_line
  end
end
