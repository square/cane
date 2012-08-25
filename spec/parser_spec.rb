require 'spec_helper'
require "stringio"
require 'cane/cli/parser'

describe Cane::CLI::Parser do
  def run(cli_args)
    result = nil
    output = StringIO.new("")
    result = Cane::CLI::Parser.new(output).parse(cli_args.split(/\s+/m))

    [output.string, result]
  end

  it 'allows style options to be configured' do
    output, result = run("--style-glob myfile --style-measure 3")
    result[:style_glob].should == 'myfile'
    result[:style_measure].should == 3
  end

  it 'displays a help message' do
    output, result = run("--help")

    result.should be
    output.should include("Usage:")
  end

  it 'handles invalid options by showing help' do
    output, result = run("--bogus")

    output.should include("Usage:")
    result.should_not be
  end

  it 'displays version' do
    output, result = run("--version")

    result.should be
    output.should include(Cane::VERSION)
  end

  it 'supports exclusions' do
    options = [
      "--abc-exclude", "Harness#complex_method",
      "--style-exclude", 'myfile'
    ].join(' ')

    _, result = run(options)
    result[:abc_exclude].should == [['Harness#complex_method']]
    result[:style_exclude].should == [['myfile']]
  end

  describe 'argument ordering' do
    it 'gives precedence to the last argument #1' do
      _, result = run("--doc-glob myfile --no-doc")
      result[:no_doc].should be

      _, result = run("--no-doc --doc-glob myfile")
      result[:no_doc].should_not be
    end
  end
end
