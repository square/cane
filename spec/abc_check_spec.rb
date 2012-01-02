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
    violations[0].to_s.should include("Harness")
    violations[0].to_s.should include("complex_method")
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
end
