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
    expect(result[:style_glob]).to eq('myfile')
    expect(result[:style_measure]).to eq(3)
  end

  it 'allows checking gte of a value in a file' do
    output, result = run("--gte myfile,90")
    expect(result[:gte]).to eq([['myfile', '90']])
  end

  it 'allows checking eq of a value in a file' do
    output, result = run("--eq myfile,90")
    expect(result[:eq]).to eq([['myfile', '90']])
  end

  it 'allows checking lte of a value in a file' do
    output, result = run("--lte myfile,90")
    expect(result[:lte]).to eq([['myfile', '90']])
  end

  it 'allows checking lt of a value in a file' do
    output, result = run("--lt myfile,90")
    expect(result[:lt]).to eq([['myfile', '90']])
  end

  it 'allows checking gt of a value in a file' do
    output, resugt = run("--gt myfile,90")
    expect(resugt[:gt]).to eq([['myfile', '90']])
  end

  it 'allows upper bound of failed checks' do
    output, result = run("--max-violations 1")
    expect(result[:max_violations]).to eq(1)
  end

  it 'uses positional arguments as shortcut for individual files' do
    output, result = run("--all mysinglefile")
    expect(result[:abc_glob]).to eq('mysinglefile')
    expect(result[:style_glob]).to eq('mysinglefile')
    expect(result[:doc_glob]).to eq('mysinglefile')

    output, result = run("--all mysinglefile --abc-glob myotherfile")
    expect(result[:abc_glob]).to eq('myotherfile')
    expect(result[:style_glob]).to eq('mysinglefile')
    expect(result[:doc_glob]).to eq('mysinglefile')
  end

  it 'displays a help message' do
    output, result = run("--help")

    expect(result).to be
    expect(output).to include("Usage:")
  end

  it 'handles invalid options by showing help' do
    output, result = run("--bogus")

    expect(output).to include("Usage:")
    expect(result).not_to be
  end

  it 'displays version' do
    output, result = run("--version")

    expect(result).to be
    expect(output).to include(Cane::VERSION)
  end

  it 'supports exclusions' do
    options = [
      "--abc-exclude", "Harness#complex_method",
      "--doc-exclude", 'myfile',
      "--style-exclude", 'myfile'
    ].join(' ')

    _, result = run(options)
    expect(result[:abc_exclude]).to eq([['Harness#complex_method']])
    expect(result[:doc_exclude]).to eq([['myfile']])
    expect(result[:style_exclude]).to eq([['myfile']])
  end

  describe 'argument ordering' do
    it 'gives precedence to the last argument #1' do
      _, result = run("--doc-glob myfile --no-doc")
      expect(result[:no_doc]).to be

      _, result = run("--no-doc --doc-glob myfile")
      expect(result[:no_doc]).not_to be
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
    expect(file).to receive(:exists?).with('./.cane').and_return(true)
    expect(file).to receive(:contents).with('./.cane').and_return(defaults)

    _, result = run("--style-glob myotherfile")

    expect(result[:no_doc]).to be
    expect(result[:abc_glob]).to eq('myfile')
    expect(result[:style_glob]).to eq('myotherfile')
  end

  it 'allows parallel option' do
    _, result = run("--parallel")
    expect(result[:parallel]).to be
  end

  it 'handles ambiguous options' do
    output, result = run("-abc-max")
    expect(output).to include("Usage:")
    expect(result).not_to be
  end

  it 'handles no_readme option' do
    _, result = run("--no-readme")
    expect(result[:no_readme]).to be
  end

  it 'handles json option' do
    _, result = run("--json")
    expect(result[:json]).to be
  end
end
