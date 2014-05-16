require 'spec_helper'

require 'cane/runner'

describe Cane::Runner do
  describe '#run' do
    it 'returns true iff fewer violations than max allowed' do
      expect(described_class.new(checks: [], max_violations: 0).run).to be
      expect(described_class.new(checks: [], max_violations: -1).run).not_to be
    end

    it 'returns JSON output' do
      formatter = class_double("Cane::JsonFormatter").as_stubbed_const
      expect(formatter).to receive(:new).and_return("JSON")
      buffer = StringIO.new("")

      described_class.new(
        out: buffer, checks: [], max_violations: 0, json: true
      ).run

      expect(buffer.string).to eq("JSON")
    end
  end
end
