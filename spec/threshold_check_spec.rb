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
        expect(run(:gte, 20)).to \
          have_violation('x is unavailable, should be >= 20.0')
      end
    end

    context "when the coverage threshold is incorrectly specified" do
      it do
        expect(described_class.new(gte: [['20', 'bogus_file']])).to \
          have_violation('bogus_file is not a number or a file')
      end
    end

    context 'when coverage threshold is valid' do
      before do
        file = class_double("Cane::File").as_stubbed_const
        stub_const("Cane::File", file)
        expect(file).to receive(:contents).with('x').and_return("8\n")
      end

      context '>' do
        it { expect(run(:gt, 7)).to have_no_violations }
        it {
          expect(run(:gt, 8)).to have_violation('x is 8.0, should be > 8.0')
        }
        it {
          expect(run(:gt, 9)).to have_violation('x is 8.0, should be > 9.0')
        }
      end

      context '>=' do
        it { expect(run(:gte, 7)).to have_no_violations }
        it { expect(run(:gte, 8)).to have_no_violations }
        it {
          expect(run(:gte, 9)).to have_violation('x is 8.0, should be >= 9.0')
        }
      end

      context '==' do
        it {
          expect(run(:eq, 7)).to have_violation('x is 8.0, should be == 7.0')
        }
        it { expect(run(:eq, 8)).to have_no_violations }
        it {
          expect(run(:eq, 9)).to have_violation('x is 8.0, should be == 9.0')
        }
      end

      context '<=' do
        it {
          expect(run(:lte, 7)).to have_violation('x is 8.0, should be <= 7.0')
        }
        it { expect(run(:lte, 8)).to have_no_violations }
        it { expect(run(:lte, 9)).to have_no_violations }
      end

      context '<' do
        it {
          expect(run(:lt, 7)).to have_violation('x is 8.0, should be < 7.0')
        }
        it {
          expect(run(:lt, 8)).to have_violation('x is 8.0, should be < 8.0')
        }
        it { expect(run(:lt, 9)).to have_no_violations }
      end
    end

  end

  context "normalizing a user supplied value to a threshold" do
    it "normalizes an integer to itself" do
      expect(subject.normalized_limit(99)).to eq(99)
    end

    it "normalizes a float to itself" do
      expect(subject.normalized_limit(99.6)).to eq(99.6)
    end

    it "normalizes a valid file to its contents" do
      expect(subject.normalized_limit(make_file('99.5'))).to eq(99.5)
    end

    it "normalizes an invalid file to an unavailable value" do
      limit = subject.normalized_limit("/File.does.not.exist")
      expect(limit).to be_a Cane::ThresholdCheck::UnavailableValue
    end


    it 'normalizes a json file to a float' do
      expect(subject.normalized_limit(make_file(simplecov_last_run))).to eq(
        93.88
      )
    end

  end

end
