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

  def self.it_should_extract_method_name(method_name, label=method_name)
    it "creates an AbcMaxViolation for #{method_name}" do
      file_name = make_file(<<-RUBY)
        class Harness
          def #{method_name}(a)
            b = a
            return b if b > 3
          end
        end
      RUBY

      violations = described_class.new(files: file_name, max: 1).violations
      violations[0].detail.should == "Harness > #{label}"
    end
  end

  # These method names all create different ASTs. Which is weird.
  it_should_extract_method_name 'a'
  it_should_extract_method_name 'self.a', 'a'
  it_should_extract_method_name 'next'
  it_should_extract_method_name 'GET'
  it_should_extract_method_name '`'
  it_should_extract_method_name '>='
end
