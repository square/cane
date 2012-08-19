require 'spec_helper'

require 'cane/style_check'

describe Cane::StyleCheck do
  def check(file_name, opts = {})
    described_class.new(opts.merge(glob: file_name))
  end

  let(:ruby_with_style_issue) do
    [
      "def test  ",
      "\t1",
      "end"
    ].join("\n")
  end

  it 'creates a StyleViolation for each method above the threshold' do
    file_name = make_file(ruby_with_style_issue)

    violations = check(file_name, measure: 80).violations
    violations.length.should == 2
  end

  it 'skips declared exclusions' do
    file_name = make_file(ruby_with_style_issue)

    violations = check(file_name,
      measure:    80,
      exclusions: [file_name]
    ).violations

    violations.length.should == 0
  end
end
