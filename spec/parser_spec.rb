require 'spec_helper'
require "stringio"
require 'cane/cli/parser'

describe Cane::CLI::Parser do
  def run(cli_args)
    result = nil
    output = StringIO.new("")
    result = Cane::CLI::Parser.new(output).parse(cli_args.split(/\s+/m))

    [output.string, result ? 0 : 1]
  end

  it 'displays a help message' do
    output, exitstatus = run("--help")

    exitstatus.should == 0
    output.should include("Usage:")
  end

  it 'displays version' do
    output, exitstatus = run("--version")

    exitstatus.should == 0
    output.should include(Cane::VERSION)
  end
end
