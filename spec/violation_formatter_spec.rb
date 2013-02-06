require 'spec_helper'

require 'cane/violation_formatter'

describe Cane::ViolationFormatter do
  def violation(description)
    {
      description: description
    }
  end

  it 'includes number of violations in the group header' do
    described_class.new([violation("FAIL")]).to_s.should include("(1)")
  end

  it 'includes total number of violations' do
    violations = [violation("FAIL1"), violation("FAIL2")]
    result = described_class.new(violations).to_s
    result.should include("Total Violations: 2")
  end

  it 'does not colorize output by default' do
    result = described_class.new([violation("FAIL")]).to_s
    result.should_not include("\e[31m")
  end

  it 'colorizes output when passed color: true' do
    result = described_class.new([violation("FAIL")], color: true).to_s
    result.should include("\e[31m")
    result.should include("\e[0m")
  end

  it 'does not colorize output if max_violations is not crossed' do
    options = { color: true, max_violations: 1 }
    result = described_class.new([violation("FAIL")], options).to_s

    result.should_not include("\e[31m")
  end
end
