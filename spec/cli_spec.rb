require 'spec_helper'

require 'cane/cli'

describe Cane::CLI do
  describe '.run' do

    let!(:parser) { class_double("Cane::CLI::Parser").as_stubbed_const }
    let!(:cane)   { class_double("Cane").as_stubbed_const }

    it 'runs Cane with the given arguments' do
      parser.should_receive(:parse).with("--args").and_return(args: true)
      cane.should_receive(:run).with(args: true).and_return("tracer")

      described_class.run("--args").should == "tracer"
    end

    it 'does not run Cane if parser was able to handle input' do
      parser.should_receive(:parse).with("--args").and_return("tracer")

      described_class.run("--args").should == "tracer"
    end
  end
end
