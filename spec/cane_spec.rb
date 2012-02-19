require 'spec_helper'
require "stringio"
require 'cane/cli'

describe 'Cane' do
  def capture_stdout &block
    real_stdout, $stdout = $stdout, StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = real_stdout
  end

  def run(cli_args)
    result = nil
    output = capture_stdout do
      result = Cane::CLI.run(cli_args.split(' '))
    end

    [output, result ? 0 : 1]
  end

  it 'fails if ABC metric does not meet requirements' do
    file_name = make_file(<<-RUBY)
      class Harness
        def complex_method(a)
          if a < 2
            return "low"
          else
            return "high"
          end
        end
      end
    RUBY

    _, exitstatus = run("--abc-glob #{file_name} --abc-max 1")

    exitstatus.should == 1
  end

  it 'fails if style metrics do not meet requirements' do
    file_name = make_file("whitespace ")

    output, exitstatus = run("--style-glob #{file_name}")
    exitstatus.should == 1
    output.should include("Lines violated style requirements")
  end

  it 'allows measure to be configured' do
    file_name = make_file("toolong")

    output, exitstatus = run("--style-glob #{file_name} --style-measure 3")
    exitstatus.should == 1
    output.should include("Lines violated style requirements")
  end

  it 'allows upper bound of failed checks' do
    file_name = make_file("whitespace ")

    output, exitstatus = run("--style-glob #{file_name} --max-violations 1")
    exitstatus.should == 0
    output.should include("Lines violated style requirements")
  end

  it 'allows checking of a value in a file' do
    file_name = make_file("89")

    output, exitstatus = run("--gte #{file_name},90")
    exitstatus.should == 1
    output.should include("Quality threshold crossed")
  end

  it 'allows checking of class documentation' do
    file_name = make_file("class NoDoc")

    output, exitstatus = run("--doc-glob #{file_name}")
    exitstatus.should == 1
    output.should include("Classes are not documented")
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

  it 'uses the last of conflicting arguments' do
    file_name = make_file("class NoDoc")

    run("--doc-glob #{file_name} --no-doc").should ==
      run("--no-doc")

    run("--no-doc --doc-glob #{file_name}").should ==
      run("--doc-glob #{file_name}")
  end
end
