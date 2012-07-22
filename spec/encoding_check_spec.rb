require 'spec_helper'

require 'cane/encoding_check'

describe Cane::EncodingCheck do
  context "with a source file that has no encoding marker" do
    let!(:file_name) {
      make_file <<-RUBY
puts "chunky bacon"
      RUBY
    }

    it 'creates an EncodingViolation' do
      violations = described_class.new(files: file_name).violations
      violations.length.should == 1

      violations[0].should be_instance_of(Cane::NoEncodingViolation)
      violations[0].file_name.should == file_name
    end
  end

  context "with a source file that has an encoding marker on line 1" do
    let!(:file_name) {
      make_file <<-RUBY
# coding: utf-8
puts "chunky bacon"
      RUBY
    }

    it 'creates no violationsn' do
      violations = described_class.new(files: file_name).violations
      violations.length.should == 0
    end
  end

  context "with a source file that has an encoding marker on line 2" do
    let!(:file_name) {
      make_file <<-RUBY
#!/bin/env ruby
# coding: utf-8
puts "chunky bacon"
      RUBY
    }

    it 'creates no violationsn' do
      violations = described_class.new(files: file_name).violations
      violations.length.should == 0
    end
  end

end
