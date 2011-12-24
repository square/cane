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

  def run(args)
    capture_stdout do
      result = Cane::CLI.run(%w(--no-style --no-abc) + args.split(' '))
      if result
        `echo 1`
      else
        `bash -c "exit 1"`
      end
    end
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

    run("--abc-glob #{file_name} --abc-max 1")
    $?.exitstatus.should == 1
  end

  it 'fails if style metrics do not meet requirements' do
    file_name = make_file("whitespace ")

    output = run("--style-glob #{file_name}")
    $?.exitstatus.should == 1
    output.should include("Lines violated style requirements")
  end

  it 'allows checking of a value in a file' do
    file_name = make_file("89")

    output = run("--gte #{file_name},90")
    $?.exitstatus.should == 1
    output.should include("Quality threshold crossed")
  end

  it 'allows checking to be disabled' do
    file_name = make_file(<<-RUBY + ' ')
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

    output = run("--no-style --no-abc")
    $?.exitstatus.should == 0
  end
end
