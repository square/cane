require 'xspec_helper'
require "stringio"
require 'cane/cli/parser'

describe Cane::CLI::Parser do
  let(:reader) {
    x = class_double("Cane::File")
    allow(x).exists?('./.cane')
    x
  }

  def run(cli_args)
    result = nil
    output = StringIO.new("")
    result = Cane::CLI::Parser
      .new(output, reader)
      .parse(cli_args.split(/\s+/m))

    [output.string, result]
  end

  it 'allows style options to be configured' do
    output, result = run("--style-glob myfile --style-measure 3")
    assert_equal 'myfile', result[:style_glob]
    assert_equal  3, result[:style_measure]
  end

  it 'allows checking gte of a value in a file' do
    output, result = run("--gte myfile,90")
    assert_equal [['myfile', '90']], result[:gte]
  end

  it 'allows checking eq of a value in a file' do
    output, result = run("--eq myfile,90")
    assert_equal  [['myfile', '90']], result[:eq]
  end

  it 'allows checking lte of a value in a file' do
    output, result = run("--lte myfile,90")
    assert_equal [['myfile', '90']], result[:lte]
  end

  it 'allows checking lt of a value in a file' do
    output, result = run("--lt myfile,90")
    assert_equal [['myfile', '90']], result[:lt]
  end

  it 'allows checking gt of a value in a file' do
    output, resugt = run("--gt myfile,90")
    assert_equal [['myfile', '90']], resugt[:gt]
  end

  it 'allows upper bound of failed checks' do
    output, result = run("--max-violations 1")
    assert_equal 1, result[:max_violations]
  end

  it 'uses positional arguments as shortcut for individual files' do
    output, result = run("--all mysinglefile")
    assert_equal 'mysinglefile', result[:abc_glob]
    assert_equal 'mysinglefile', result[:style_glob]
    assert_equal 'mysinglefile', result[:doc_glob]

    output, result = run("--all mysinglefile --abc-glob myotherfile")
    assert_equal 'myotherfile', result[:abc_glob]
    assert_equal 'mysinglefile', result[:style_glob]
    assert_equal 'mysinglefile', result[:doc_glob]
  end

  it 'displays a help message' do
    output, result = run("--help")

    assert result
    assert_include "Usage:", output
  end

  it 'handles invalid options by showing help' do
    output, result = run("--bogus")

    assert !result
    assert_include "Usage:", output
  end

  it 'displays version' do
    output, result = run("--version")

    assert result
    assert_include Cane::VERSION, output
  end

  it 'supports exclusions' do
    options = [
      "--abc-exclude", "Harness#complex_method",
      "--doc-exclude", 'myfile',
      "--style-exclude", 'myfile'
    ].join(' ')

    _, result = run(options)
    assert_equal [['Harness#complex_method']], result[:abc_exclude]
    assert_equal [['myfile']], result[:doc_exclude]
    assert_equal [['myfile']], result[:style_exclude]
  end

  describe 'argument ordering' do
    it 'gives precedence to the last argument #1' do
      _, result = run("--doc-glob myfile --no-doc")
      assert result[:no_doc]

      _, result = run("--no-doc --doc-glob myfile")
      assert !result[:no_doc]
    end
  end

  it 'loads default options from .cane file' do
    defaults = <<-EOS
      --no-doc
      --abc-glob myfile
      --style-glob myfile
    EOS
    expect(reader).exists?('./.cane') { true }
    expect(reader).contents('./.cane') { defaults }

    _, result = run("--style-glob myotherfile")

    assert result[:no_doc]
    assert_equal 'myfile', result[:abc_glob]
    assert_equal 'myotherfile', result[:style_glob]
  end

  it 'allows parallel option' do
    _, result = run("--parallel")
    assert result[:parallel]
  end

  it 'handles ambiguous options' do
    output, result = run("-abc-max")
    assert_include "Usage:", output
    assert !result
  end

  it 'handles no_readme option' do
    _, result = run("--no-readme")
    assert result[:no_readme]
  end

  it 'handles json option' do
    _, result = run("--json")
    assert result[:json]
  end
end
