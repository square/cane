require 'xspec_helper'

require 'cane/threshold_check'

describe Cane::ThresholdCheck do
  let(:reader) { class_double("Cane::File") }

  let(:simplecov_last_run) do
    <<-ENDL
    {
      "result": {
        "covered_percent": 93.88
      }
    }
    ENDL
  end

  describe "checking violations" do
    def run(threshold, value)
      Cane::ThresholdCheck.new(reader: reader, threshold => [['x', value]])
    end

    describe "when the current coverage cannot be read" do
      it do
        expect(reader).contents('x') { raise Errno::ENOENT }
        assert_violation 'x is unavailable, should be >= 20.0', run(:gte, 20)
      end
    end

    describe "when the coverage threshold is incorrectly specified" do
      it do
        assert_violation 'bogus_file is not a number or a file',
          Cane::ThresholdCheck.new(gte: [['20', 'bogus_file']])
      end
    end

    describe 'when coverage threshold is valid' do
      def run(threshold, value)
        expect(reader).contents('x') { "8\n" }
        super
      end

      describe '>' do
        it { assert_no_violations run(:gt, 7) }
        it { assert_violation 'x is 8.0, should be > 8.0', run(:gt, 8) }
        it { assert_violation 'x is 8.0, should be > 9.0', run(:gt, 9) }
      end

      describe '>=' do
        it { assert_no_violations run(:gte, 7) }
        it { assert_no_violations run(:gte, 8) }
        it { assert_violation 'x is 8.0, should be >= 9.0', run(:gte, 9) }
      end

      describe '==' do
        it { assert_violation 'x is 8.0, should be == 7.0', run(:eq, 7) }
        it { assert_no_violations run(:eq, 8) }
        it { assert_violation 'x is 8.0, should be == 9.0', run(:eq, 9) }
      end

      describe '<=' do
        it { assert_violation 'x is 8.0, should be <= 7.0', run(:lte, 7) }
        it { assert_no_violations run(:lte, 8) }
        it { assert_no_violations run(:lte, 9) }
      end

      describe '<' do
        it { assert_violation 'x is 8.0, should be < 7.0', run(:lt, 7) }
        it { assert_violation 'x is 8.0, should be < 8.0', run(:lt, 8) }
        it { assert_no_violations run(:lt, 9) }
      end
    end

  end

  describe "normalizing a user supplied value to a threshold" do
    let(:subject) { Cane::ThresholdCheck.new({}) }

    it "normalizes an integer to itself" do
      assert_equal 99, subject.normalized_limit(99)
    end

    it "normalizes a float to itself" do
      assert_equal 99.6, subject.normalized_limit(99.6)
    end

    it "normalizes a valid file to its contents" do
      assert_equal 99.5, subject.normalized_limit(make_file('99.5'))
    end

    it "normalizes an invalid file to an unavailable value" do
      limit = subject.normalized_limit("/File.does.not.exist")
      assert limit.is_a?(Cane::ThresholdCheck::UnavailableValue)
    end

    it 'normalizes a json file to a float' do
      assert_equal 93.88,
        subject.normalized_limit(make_file(simplecov_last_run))
    end

  end

end
