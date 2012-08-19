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
end
