require 'spec_helper'

require 'cane/doc_check'

describe Cane::DocCheck do
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

    violations = described_class.new(files: file_name).violations
    violations.length.should == 2

    violations[0].should be_instance_of(Cane::UndocumentedClassViolation)
    violations[0].file_name.should == file_name
    violations[0].number.should == 3

    violations[1].should be_instance_of(Cane::UndocumentedClassViolation)
    violations[1].file_name.should == file_name
    violations[1].number.should == 4
  end
end
