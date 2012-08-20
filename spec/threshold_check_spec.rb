require 'spec_helper'

require 'cane/threshold_check'

describe Cane::ThresholdCheck do
  it 'returns a value of unavailable when file cannot be read' do
    check = Cane::ThresholdCheck.new(gte: [['bogus_file', 20]])
    violations = check.violations
    violations.length.should == 1
    violations[0][:label].should ==
      'bogus_file is unavailable, should be >= 20'
  end
end
