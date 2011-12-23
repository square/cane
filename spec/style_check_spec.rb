require 'spec_helper'

require 'cane/style_check'

describe Cane::StyleCheck do
  it 'creates a StyleViolation for each method above the threshold' do
    ruby = [
      "def test  ",
      "\t1",
      "end"
    ].join("\n")
    file_name = make_file(ruby)

    violations = Cane::StyleCheck.new(files: file_name, max: 1).violations
    violations.length.should == 2
    violations[0].should be_instance_of(StyleViolation)
  end
end
