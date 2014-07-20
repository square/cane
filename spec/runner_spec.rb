require 'xspec_helper'

require 'cane/runner'

describe Cane::Runner do
  describe '#run' do
    it 'returns true iff fewer violations than max allowed' do
      assert  Cane::Runner.new(checks: [], max_violations: 0).run
      assert !Cane::Runner.new(checks: [], max_violations: -1).run
    end

    it 'returns JSON output' do
      buffer = StringIO.new("")

      Cane::Runner.new(
        out:            buffer,
        checks:         [],
        max_violations: 0,
        json:           true
      ).run

      assert_equal "[]", buffer.string
    end
  end
end
