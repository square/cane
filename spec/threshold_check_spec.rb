require 'spec_helper'

require 'cane/threshold_check'

describe Cane::ThresholdCheck do

  context "checking violations" do

    def check(opts = {})
      Cane::ThresholdCheck.new(opts)
    end

    context "when the current coverage cannot be read" do
      it do
        check(gte: [['bogus_file', '20']]).should \
          have_violation('bogus_file is unavailable, should be >= 20.0')
      end
    end

    context "when the coverage threshold is incorrectly specified" do
      it do
        check(gte: [['20', 'bogus_file']]).should \
          have_violation('bogus_file is not a number or a file')
      end
    end

    context '>= threshold' do
      before do
        file = fire_replaced_class_double("Cane::File")
        stub_const("Cane::File", file)
        file.should_receive(:contents).with('myfile').and_return("98\n")
      end

      it do
        check(gte: [['myfile', '99']]).should \
          have_violation('myfile is 98.0, should be >= 99.0')
      end

      it do
        check(gte: [['myfile', '98']]).should have_no_violations
      end
    end

    context '== threshold' do
      before do
        file = fire_replaced_class_double("Cane::File")
        stub_const("Cane::File", file)
        file.should_receive(:contents).with('myfile').and_return("98\n")
      end

      it do
        check(eq: [['myfile', '99']]).should \
          have_violation('myfile is 98.0, should be == 99.0')
      end

      it do
        check(eq: [['myfile', '100']]).should \
          have_violation('myfile is 98.0, should be == 100.0')
      end

      it 'allows equal value' do
        check(eq: [['myfile', '98']]).should have_no_violations
      end
    end

  end

  context "normalizing a user supplied value to a threshold" do
    it "normalizes an integer to itself" do
      subject.normalized_limit(99).should == 99
    end

    it "normalizes a float to itself" do
      subject.normalized_limit(99.6).should == 99.6
    end

    it "normalizes a valid file to its contents" do
      subject.normalized_limit(make_file('99.5')).should == 99.5
    end

    it "normalizes an invalid file to an unavailable value" do
      limit = subject.normalized_limit("/File.does.not.exist")
      limit.should be_a Cane::ThresholdCheck::UnavailableValue
    end
  end

end
