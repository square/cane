require 'spec_helper'

require 'cane/abc_check'

describe Cane::AbcCheck do
  def check(file_name, opts = {})
    described_class.new(opts.merge(abc_glob: file_name))
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
    expect(violations).to be_empty
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
    expect(violations.length).to eq(1)
    expect(violations[0].values_at(:file, :label, :value)).to eq(
      [file_name, "Harness#complex_method", 2]
    )
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
    expect(violations.length).to eq(2)
    complexities = violations.map {|x| x[:value] }
    expect(complexities).to eq(complexities.sort.reverse)
  end

  it 'creates a violation when code cannot be parsed' do
    file_name = make_file(<<-RUBY)
      class Harness
    RUBY

    violations = check(file_name).violations
    expect(violations.length).to eq(1)
    expect(violations[0][:file]).to eq(file_name)
    expect(violations[0][:description]).to be_instance_of(String)
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
    expect(violations.length).to eq(1)
    expect(violations[0].values_at(:file, :label, :value)).to eq(
      [file_name, "Harness::Nested#other_meth", 1]
    )
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
    violations[0][:label] == "MyClass#test_method"
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
    expect(violations[0][:label]).to eq("(anon)#test_method")
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
      expect(violations[0][:label]).to eq("Harness#{sep}#{label}")
    end
  end

  # These method names all create different ASTs. Which is weird.
  it_should_extract_method_name 'a'
  it_should_extract_method_name 'self.a', 'a', '.'
  it_should_extract_method_name 'next'
  it_should_extract_method_name 'GET'
  it_should_extract_method_name '`'
  it_should_extract_method_name '>='

  describe "#file_names" do
    context "abc_glob is an array" do
      it "returns an array of relative file paths" do
        glob = [
          'spec/fixtures/a/**/*.{rb,prawn}',
          'spec/fixtures/b/**/*.rb'
        ]
        check = described_class.new(abc_glob: glob)
        expect(check.send(:file_names)).to eq([
          'spec/fixtures/a/1.rb',
          'spec/fixtures/a/3.prawn',
          'spec/fixtures/b/1.rb'
        ])
      end
    end
  end
end
