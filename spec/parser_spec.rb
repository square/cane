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

  it 'allows checking gte of a value in a file' do
    output, result = run("--gte myfile,90")
    result[:gte].should == [['myfile', '90']]
  end

  it 'allows checking eq of a value in a file' do
    output, result = run("--eq myfile,90")
    result[:eq].should == [['myfile', '90']]
  end

  it 'allows checking lte of a value in a file' do
    output, result = run("--lte myfile,90")
    result[:lte].should == [['myfile', '90']]
  end

  it 'allows checking lt of a value in a file' do
    output, result = run("--lt myfile,90")
    result[:lt].should == [['myfile', '90']]
  end

  it 'allows checking gt of a value in a file' do
    output, resugt = run("--gt myfile,90")
    resugt[:gt].should == [['myfile', '90']]
  end

  it 'allows upper bound of failed checks' do
    output, result = run("--max-violations 1")
    result[:max_violations].should == 1
  end

  it 'uses positional arguments as shortcut for individual files' do
    output, result = run("--all mysinglefile")
    result[:abc_glob].should == 'mysinglefile'
    result[:style_glob].should == 'mysinglefile'
    result[:doc_glob].should == 'mysinglefile'

    output, result = run("--all mysinglefile --abc-glob myotherfile")
    result[:abc_glob].should == 'myotherfile'
    result[:style_glob].should == 'mysinglefile'
    result[:doc_glob].should == 'mysinglefile'
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
      "--doc-exclude", 'myfile',
      "--style-exclude", 'myfile'
    ].join(' ')

    _, result = run(options)
    result[:abc_exclude].should == [['Harness#complex_method']]
    result[:doc_exclude].should == [['myfile']]
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

  it 'loads default options from .cane file' do
    defaults = <<-EOS
      --no-doc
      --abc-glob myfile
      --style-glob myfile
    EOS
    file = class_double("Cane::File").as_stubbed_const
    stub_const("Cane::File", file)
    file.should_receive(:exists?).with('./.cane').and_return(true)
    file.should_receive(:contents).with('./.cane').and_return(defaults)

    _, result = run("--style-glob myotherfile")

    result[:no_doc].should be
    result[:abc_glob].should == 'myfile'
    result[:style_glob].should == 'myotherfile'
  end

  it 'allows parallel option' do
    _, result = run("--parallel")
    result[:parallel].should be
  end

  it 'handles ambiguous options' do
    output, result = run("-abc-max")
    output.should include("Usage:")
    result.should_not be
  end

  it 'handles no_readme option' do
    _, result = run("--no-readme")
    result[:no_readme].should be
  end

  it 'handles json option' do
    _, result = run("--json")
    result[:json].should be
  end
end
