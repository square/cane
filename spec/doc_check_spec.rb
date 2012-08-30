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
class NoDoc; end # No doc
  class AlsoNoDoc; end
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
end
