require 'spec_helper'

require 'cane/doc_check'

describe Cane::DocCheck do
  def check(file_name, opts = {})
    described_class.new(opts.merge(doc_glob: file_name))
  end

  it 'creates a DocViolation for each undocumented class' do
    file_name = make_file <<-RUBY
# This class is documented
class Doc; end
class  NoDoc; end # No doc
  class AlsoNoDoc; end
classIgnore = nil
[:class]
# class Ignore
class Meta
  class << self; end
end
    RUBY

    violations = check(file_name).violations
    violations.length.should == 2

    violations[0].values_at(:file, :line, :label).should == [
      file_name, 3, "NoDoc"
    ]

    violations[1].values_at(:file, :line, :label).should == [
      file_name, 4, "AlsoNoDoc"
    ]
  end

  it 'ignores magic encoding comments' do
    file_name = make_file <<-RUBY
# coding = utf-8
class NoDoc; end
# -*-  encoding :  utf-8  -*-
class AlsoNoDoc; end
# Parse a Transfer-Encoding: Chunked response
class Doc; end
    RUBY

    violations = check(file_name).violations
    violations.length.should == 2

    violations[0].values_at(:file, :line, :label).should == [
      file_name, 2, "NoDoc"
    ]
    violations[1].values_at(:file, :line, :label).should == [
      file_name, 4, "AlsoNoDoc"
    ]
  end

  it 'creates a violation for missing README' do
    file = fire_replaced_class_double("Cane::File")
    stub_const("Cane::File", file)
    file.should_receive(:exists?).with("README").and_return(false)
    file.should_receive(:exists?).with("README.md").and_return(false)
    file.should_receive(:exists?).with("README.mdown").and_return(false)
    file.should_receive(:exists?).with("README.markdown").and_return(false)
    file.should_receive(:exists?).with("README.textile").and_return(false)
    file.should_receive(:exists?).with("README.txt").and_return(false)
    file.should_receive(:exists?).with("README.rdoc").and_return(false)
    file.should_receive(:exists?).with("readme").and_return(false)
    file.should_receive(:exists?).with("readme.md").and_return(false)
    file.should_receive(:exists?).with("readme.mdown").and_return(false)
    file.should_receive(:exists?).with("readme.markdown").and_return(false)
    file.should_receive(:exists?).with("readme.textile").and_return(false)
    file.should_receive(:exists?).with("readme.txt").and_return(false)
    file.should_receive(:exists?).with("readme.rdoc").and_return(false)

    violations = check("").violations
    violations.length.should == 1

    violations[0].values_at(:description, :label).should == [
      "Missing documentation", "No README found"
    ]
  end

  it 'skips declared exclusions' do
    file_name = make_file <<-FILE.gsub /^\s{6}/, ''
      class NeedsDocumentation
      end
    FILE

    violations = check(file_name,
      doc_exclude: [file_name]
    ).violations

    violations.length.should == 0
  end

  it 'skips declared glob-based exclusions' do
    file_name = make_file <<-FILE.gsub /^\s{6}/, ''
      class NeedsDocumentation
      end
    FILE

    violations = check(file_name,
      doc_exclude: ["#{File.dirname(file_name)}/*"]
    ).violations

    violations.length.should == 0
  end

  it 'skips class inside an array' do
    file_name = make_file <<-RUBY
    %w(
      class
      method
    )
    RUBY

    violations = check(file_name).violations
    violations.length.should == 0
  end
end
