require 'spec_helper'

require 'cane/doc_check'

describe Cane::DocCheck do
  def check(file_name, opts = {})
    described_class.new(opts.merge(doc_glob: file_name))
  end

  it 'creates a DocViolation for each undocumented class with a method' do
    file_name = make_file <<-RUBY
class Doc; end
class  Empty; end # No doc is fine
  class NoDoc; def with_method; end; end
classIgnore = nil
[:class]
# class Ignore
class Meta
  class << self; end
end
module DontNeedDoc; end
# This module is documented
module HasDoc
  def mixin; end
end
module AlsoNeedsDoc; def mixin; end; end
module NoDocIsFine
  module ButThisNeedsDoc
    def self.global
    end
  end
  module AlsoNoDocIsFine; end
  # We've got docs
  module CauseWeNeedThem
    def mixin
    end
  end
end
module NoViolationCozComment
  # def method should ignore this comment
  # end
end
    RUBY

    violations = check(file_name).violations
    violations.length.should == 3

    violations[0].values_at(:file, :line, :label).should == [
      file_name, 3, "NoDoc"
    ]

    violations[1].values_at(:file, :line, :label).should == [
      file_name, 15, "AlsoNeedsDoc"
    ]

    violations[2].values_at(:file, :line, :label).should == [
      file_name, 17, "ButThisNeedsDoc"
    ]
  end

  it 'does not create violations for single line classes without methods' do
    file_name = make_file <<-RUBY
class NeedsDoc
  class AlsoNeedsDoc < StandardError; def foo; end; end
  class NoDocIsOk < StandardError; end
  class NoDocIsAlsoOk < StandardError; end # No doc is fine on this too

  def my_method
  end
end
RUBY

    violations = check(file_name).violations
    violations.length.should == 2

    violations[0].values_at(:file, :line, :label).should == [
      file_name, 1, "NeedsDoc"
    ]

    violations[1].values_at(:file, :line, :label).should == [
      file_name, 2, "AlsoNeedsDoc"
    ]
  end

  it 'ignores magic encoding comments' do
    file_name = make_file <<-RUBY
# coding = utf-8
class NoDoc; def do_stuff; end; end
# -*-  encoding :  utf-8  -*-
class AlsoNoDoc; def do_more_stuff; end; end
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
    file = class_double("Cane::File").as_stubbed_const
    stub_const("Cane::File", file)
    file.should_receive(:case_insensitive_glob).with("README*").and_return([])

    violations = check("").violations
    violations.length.should == 1

    violations[0].values_at(:description, :label).should == [
      "Missing documentation", "No README found"
    ]
  end

  it 'does not create a violation when readme exists' do
    file = class_double("Cane::File").as_stubbed_const
    stub_const("Cane::File", file)
    file
      .should_receive(:case_insensitive_glob)
      .with("README*")
      .and_return(%w(readme.md))

    violations = check("").violations
    violations.length.should == 0
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
