require 'spec_helper'

require 'cane/runner'

describe Cane::Runner do
  describe '#run' do
    it 'returns true iff fewer violations than max allowed' do
      described_class.new(checks: [], max_violations: 0).run.should be
      described_class.new(checks: [], max_violations: -1).run.should_not be
    end
  end
end
