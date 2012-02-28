require 'spec_helper'

describe Cane::ColoredFormatter do
  class Color
    extend Term::ANSIColor
  end

  def violation(description)
    stub("violation",
      description: description,
      columns: ["app/foo.rb:1", "MyClass"]
    )
  end

  def violations(count, description)
    (0...count).map { violation(description) }
  end

  context "group header" do
    it "has a description" do
      output = [Color.white, "FAIL", Color.reset].join
      described_class.new(violations(1, "FAIL")).to_s.should include(output)
    end

    context "number of violations" do
      it 'for 1..5' do
        output = "(#{Color.yellow}1#{Color.reset})"
        described_class.new(violations(1,"FAIL")).to_s.should include(output)
      end

      it 'for 6..10' do
        output = "(#{Color.red}6#{Color.reset})"
        described_class.new(violations(6,"FAIL")).to_s.should include(output)
      end

      it 'for 11..Infinity' do
        output = "(#{Color.bold}#{Color.red}11#{Color.reset})"
        described_class.new(violations(11,"FAIL")).to_s.should include(output)
      end
    end
  end

  context "file violations" do
    it "colorizes the file name" do
      output = [Color.yellow, "app/foo.rb", Color.clear, ":1"].join
      described_class.new(violations(1,"FAIL")).to_s.should include(output)
    end

    it "colorizes the class name" do
      output = [Color.red, "MyClass", Color.clear].join
      described_class.new(violations(1,"FAIL")).to_s.should include(output)
    end
  end
end
