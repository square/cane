require 'spec_helper'

require 'cane/style_check'

describe Cane::StyleCheck do
  def check(file_name, opts = {})
    described_class.new(opts.merge(style_glob: file_name))
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

    violations = check(file_name, style_measure: 8).violations
    violations.length.should == 3
  end

  it 'skips declared exclusions' do
    file_name = make_file(ruby_with_style_issue)

    violations = check(file_name,
      style_measure: 80,
      style_exclude: [file_name]
    ).violations

    violations.length.should == 0
  end

  it 'skips declared glob-based exclusions' do
    file_name = make_file(ruby_with_style_issue)

    violations = check(file_name,
      style_measure: 80,
      style_exclude: ["#{File.dirname(file_name)}/*"]
    ).violations

    violations.length.should == 0
  end

  it 'does not include trailing new lines in the character count' do
    file_name = make_file('#' * 80 + "\n" + '#' * 80)

    violations = check(file_name,
      style_measure: 80,
      style_exclude: [file_name]
    ).violations

    violations.length.should == 0
  end

end
