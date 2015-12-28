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
    expect(violations.length).to eq(3)
  end

  it 'skips declared exclusions' do
    file_name = make_file(ruby_with_style_issue)

    violations = check(file_name,
      style_measure: 80,
      style_exclude: [file_name]
    ).violations

    expect(violations.length).to eq(0)
  end

  it 'skips declared glob-based exclusions' do
    file_name = make_file(ruby_with_style_issue)

    violations = check(file_name,
      style_measure: 80,
      style_exclude: ["#{File.dirname(file_name)}/*"]
    ).violations

    expect(violations.length).to eq(0)
  end

  it 'does not include trailing new lines in the character count' do
    file_name = make_file('#' * 80 + "\n" + '#' * 80)

    violations = check(file_name,
      style_measure: 80,
      style_exclude: [file_name]
    ).violations

    expect(violations.length).to eq(0)
  end

  describe "#file_list" do
    context "style_glob is an array" do
      it "returns an array of relative file paths" do
        glob = [
          'spec/fixtures/a/**/*.{rb,prawn}',
          'spec/fixtures/b/**/*.haml'
        ]
        check = described_class.new(style_glob: glob)
        expect(check.send(:file_list)).to eq([
          'spec/fixtures/a/1.rb',
          'spec/fixtures/a/3.prawn',
          'spec/fixtures/b/3/i.haml'
        ])
      end
    end

    context "style_exclude is an array" do
      it "returns an array of relative file paths" do
        glob = [
          'spec/fixtures/a/**/*.{rb,prawn}',
          'spec/fixtures/b/**/*.haml'
        ]
        exclude = [
          'spec/fixtures/a/**/*.prawn',
          'spec/fixtures/b/**/*.haml'
        ]
        check = described_class.new(style_exclude: exclude, style_glob: glob)
        expect(check.send(:file_list)).to eq(['spec/fixtures/a/1.rb'])
      end
    end
  end
end
