require 'spec_helper'

require 'cane/violation_formatter'

describe Cane::ViolationFormatter do
  def violation(description)
    stub("violation",
      description: description,
      columns:     []
    )
  end

  it 'includes number of violations in the group header' do
    described_class.new([violation("FAIL")]).to_s.should include("(1)")
  end
end
