# encoding: utf-8
require 'spec_helper'

require 'cane/encoding_aware_iterator'

# Example bad input from:
#   http://stackoverflow.com/questions/1301402/example-invalid-utf8-string
describe Cane::EncodingAwareIterator do
  it 'handles non-UTF8 input' do
    lines = ["\xc3\x28"]
    result = described_class.new(lines).map.with_index do |line, number|
      expect(line).to be_kind_of(String)
      [line =~ /\s/, number]
    end
    expect(result).to eq([[nil, 0]])
  end

  it 'does not enter an infinite loop on persistently bad input' do
    expect{
      described_class.new([""]).map.with_index do |line, number|
        "\xc3\x28" =~ /\s/
      end
    }.to raise_error(ArgumentError)
  end

  it 'allows each with no block' do
    called_with_line = nil
    described_class.new([""]).each.with_index do |line, number|
      called_with_line = line
    end
    expect(called_with_line).to eq("")
  end
end
