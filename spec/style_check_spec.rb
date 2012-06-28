require 'spec_helper'

require 'cane/style_check'

describe Cane::StyleCheck do
  let(:ruby_with_style_issue) do
    [
      "def test  ",
      "\t1",
      "end"
    ].join("\n")
  end

  it 'creates a StyleViolation for each method above the threshold' do
    file_name = make_file(ruby_with_style_issue)

    violations = Cane::StyleCheck.new(files: file_name, measure: 80).violations
    violations.length.should == 2
    violations[0].should be_instance_of(StyleViolation)
  end

  it 'skips declared exclusions' do
    file_name = make_file(ruby_with_style_issue)

    violations = Cane::StyleCheck.new(files: file_name, measure: 80,
                                      exclusions: [file_name]).violations
    violations.length.should == 0
  end
end
