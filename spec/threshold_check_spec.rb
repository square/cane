require 'spec_helper'

require 'cane/threshold_check'

describe Cane::ThresholdCheck do

  let(:simplecov_last_run) do
    <<-ENDL
    {
      "result": {
        "covered_percent": 93.88
      }
    }
    ENDL
  end

  context "checking violations" do

    def run(threshold, value)
      described_class.new(threshold => [['x', value]])
    end

    context "when the current coverage cannot be read" do
      it do
        run(:gte, 20).should \
          have_violation('x is unavailable, should be >= 20.0')
      end
    end

    context "when the coverage threshold is incorrectly specified" do
      it do
        described_class.new(gte: [['20', 'bogus_file']]).should \
          have_violation('bogus_file is not a number or a file')
      end
    end

    context 'when coverage threshold is valid' do
      before do
        file = class_double("Cane::File").as_stubbed_const
        stub_const("Cane::File", file)
        file.should_receive(:contents).with('x').and_return("8\n")
      end

      context '>' do
        it { run(:gt, 7).should have_no_violations }
        it { run(:gt, 8).should have_violation('x is 8.0, should be > 8.0') }
        it { run(:gt, 9).should have_violation('x is 8.0, should be > 9.0') }
      end

      context '>=' do
        it { run(:gte, 7).should have_no_violations }
        it { run(:gte, 8).should have_no_violations }
        it { run(:gte, 9).should have_violation('x is 8.0, should be >= 9.0') }
      end

      context '==' do
        it { run(:eq, 7).should have_violation('x is 8.0, should be == 7.0') }
        it { run(:eq, 8).should have_no_violations }
        it { run(:eq, 9).should have_violation('x is 8.0, should be == 9.0') }
      end

      context '<=' do
        it { run(:lte, 7).should have_violation('x is 8.0, should be <= 7.0') }
        it { run(:lte, 8).should have_no_violations }
        it { run(:lte, 9).should have_no_violations }
      end

      context '<' do
        it { run(:lt, 7).should have_violation('x is 8.0, should be < 7.0') }
        it { run(:lt, 8).should have_violation('x is 8.0, should be < 8.0') }
        it { run(:lt, 9).should have_no_violations }
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


    it 'normalizes a json file to a float' do
      subject.normalized_limit(make_file(simplecov_last_run)).should == 93.88
    end

  end

end
