require 'xspec_helper'

require 'cane/abc_check'

describe Cane::AbcCheck do
  def check(file_name, opts = {})
    Cane::AbcCheck.new(opts.merge(abc_glob: file_name))
  end

  it 'does not create violations when no_abc flag is set' do
    file_name = make_file(<<-RUBY)
      class Harness
        def complex_method(a)
          b = a
          return b if b > 3
        end
      end
    RUBY

    violations = check(file_name, abc_max: 1, no_abc: true).violations
    assert_equal violations, []
  end

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

    violations = check(file_name, abc_max: 1, no_abc: false).violations
    assert_equal 1, violations.length
    assert_equal [file_name, "Harness#complex_method", 2],
      violations[0].values_at(:file, :label, :value)
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

    violations = check(file_name, abc_max: 0).violations
    assert_equal 2, violations.length
    complexities = violations.map {|x| x[:value] }
    assert_equal complexities.sort.reverse, complexities
  end

  it 'creates a violation when code cannot be parsed' do
    file_name = make_file(<<-RUBY)
      class Harness
    RUBY

    violations = check(file_name).violations
    assert_equal 1, violations.length
    assert_equal file_name, violations[0][:file]
    assert violations[0][:description].is_a?(String),
      "description not a string"
  end

  it 'skips declared exclusions' do
    file_name = make_file(<<-RUBY)
      class Harness
        def instance_meth
          true
        end

        def self.class_meth
          true
        end

        module Nested
          def i_meth
            true
          end

          def self.c_meth
            true
          end

          def other_meth
            true
          end
        end
      end
    RUBY

    exclusions = %w[ Harness#instance_meth  Harness.class_meth
                     Harness::Nested#i_meth Harness::Nested.c_meth ]
    violations = check(file_name,
      abc_max:        0,
      abc_exclude: exclusions
    ).violations
    assert_equal 1, violations.length
    assert_equal [file_name, "Harness::Nested#other_meth", 1],
      violations[0].values_at(:file, :label, :value)
  end

  it "creates an AbcMaxViolation for method in assigned anonymous class" do
    file_name = make_file(<<-RUBY)
      MyClass = Struct.new(:foo) do
        def test_method(a)
          b = a
          return b if b > 3
        end
      end
    RUBY

    violations = check(file_name, abc_max: 1).violations
    assert_equal "MyClass#test_method", violations[0][:label]
  end

  it "creates an AbcMaxViolation for method in anonymous class" do
    file_name = make_file(<<-RUBY)
      Class.new do
        def test_method(a)
          b = a
          return b if b > 3
        end
      end
    RUBY

    violations = check(file_name, abc_max: 1).violations
    assert_equal "(anon)#test_method", violations[0][:label]
  end

  def self.it_should_extract_method_name(name, label=name, sep='#')
    it "creates an AbcMaxViolation for #{name}" do
      file_name = make_file(<<-RUBY)
        class Harness
          def #{name}(a)
            b = a
            return b if b > 3
          end
        end
      RUBY

      violations = check(file_name, abc_max: 1).violations
      assert_equal "Harness#{sep}#{label}", violations[0][:label]
    end
  end

  # These method names all create different ASTs. Which is weird.
  it_should_extract_method_name 'a'
  it_should_extract_method_name 'self.a', 'a', '.'
  it_should_extract_method_name 'next'
  it_should_extract_method_name 'GET'
  it_should_extract_method_name '`'
  it_should_extract_method_name '>='
end
