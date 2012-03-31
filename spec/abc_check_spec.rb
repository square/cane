require 'spec_helper'

require 'cane/abc_check'

describe Cane::AbcCheck do
  it 'creates an AbcMaxViolation for each method above the threshold' do
    file_name = make_file(<<-RUBY)
      class Harness
        def not_complex
          true
        end

        def complex_method(a)
          b = a
          return b if b > 3
        end
      end
    RUBY

    violations = described_class.new(files: file_name, max: 1).violations
    violations.length.should == 1
    violations[0].should be_instance_of(Cane::AbcMaxViolation)
    violations[0].columns.should == [file_name, "Harness > complex_method", 2]
  end

  it 'sorts violations by complexity' do
    file_name = make_file(<<-RUBY)
      class Harness
        def not_complex
          true
        end

        def complex_method(a)
          b = a
          return b if b > 3
        end
      end
    RUBY

    violations = described_class.new(files: file_name, max: 0).violations
    violations.length.should == 2
    complexities = violations.map(&:complexity)
    complexities.should == complexities.sort.reverse
  end

  it 'creates a SyntaxViolation when code cannot be parsed' do
    file_name = make_file(<<-RUBY)
      class Harness
    RUBY

    violations = described_class.new(files: file_name).violations
    violations.length.should == 1
    violations[0].should be_instance_of(Cane::SyntaxViolation)
    violations[0].columns.should == [file_name]
    violations[0].description.should be_instance_of(String)
  end

  it 'creates an AbcMaxViolation for class methods above the threshold' do
    file_name = make_file(<<-RUBY)
      class Harness
        def self.complex_method(a)
          b = a
          return b if b > 3
        end
      end
    RUBY

    violations = described_class.new(files: file_name, max: 1).violations
    violations.length.should == 1
    violations[0].should be_instance_of(Cane::AbcMaxViolation)
    violations[0].columns.should == [file_name, "Harness > complex_method", 2]
  end
end
