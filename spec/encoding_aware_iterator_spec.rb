# encoding: utf-8
require 'spec_helper'

require 'cane/encoding_aware_iterator'

# Example bad input from:
#   http://stackoverflow.com/questions/1301402/example-invalid-utf8-string
describe Cane::EncodingAwareIterator do
  it 'handles non-UTF8 input' do
    lines = ["\xc3\x28"]
    result = described_class.new(lines).map_with_index do |line, number|
      [line =~ /\s/, number]
    end
    result.should == [[nil, 0]]
  end

  it 'does not enter an infinite loop on persistently bad input' do
    ->{
      described_class.new([""]).map_with_index do |line, number|
        "\xc3\x28" =~ /\s/
      end
    }.should raise_error(ArgumentError)
  end
end
