require 'spec_helper'

require 'cane/threshold_check'

describe ThresholdCheck do
  it 'returns a value of unavailable when file cannot be read' do
    check = ThresholdCheck.new([[:>=, 'bogus_file', 20]])
    violations = check.violations
    violations.length.should == 1
    violations[0].should include("unavailable")
  end
end
