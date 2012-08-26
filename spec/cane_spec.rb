require 'spec_helper'
require "stringio"
require 'cane/cli'

require 'cane/rake_task'

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
      result = Cane::CLI.run(['--no-abc'] + cli_args.split(/\s+/m))
    end

    [output, result ? 0 : 1]
  end

  it 'returns a non-zero exit code and a details of checks that failed' do
    fn = make_file(<<-RUBY + "  ")
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

    output, exitstatus =
      run("--style-glob #{fn} --doc-glob #{fn} --abc-glob #{fn} --abc-max 1")
    output.should include("Lines violated style requirements")
    output.should include("Classes are not documented")
    output.should include("Methods exceeded maximum allowed ABC complexity")
    exitstatus.should == 1
  end

  it 'handles invalid unicode input' do
    fn = make_file("\xc3\x28")

    _, exitstatus = run("--style-glob #{fn} --abc-glob #{fn} --doc-glob #{fn}")

    exitstatus.should == 0
  end

  # Push this down into a unit spec
  it 'handles option that does not result in a run' do
    _, exitstatus = run("--help")
    exitstatus.should == 0
  end

  describe 'user-defined checks' do
    let(:class_name) { "C#{rand(10 ** 10)}" }

    it 'allows user-defined checks' do
      fn = make_file(":(")
      check_file = make_file <<-RUBY
        class #{class_name} < Struct.new(:opts)
          def self.options
            {
              unhappy_file: ["File to check", default: [nil]]
            }
          end

          def violations
            [
              description: "Files are unhappy",
              file:        opts.fetch(:unhappy_file),
              label:       ":("
            ]
          end
        end
      RUBY

      out, exitstatus = run(%(
        -r #{check_file}
        --check #{class_name}
        --unhappy-file #{fn}
      ))
      out.should include("Files are unhappy")
      out.should include(fn)
      exitstatus.should == 1
    end

    after do
      if Object.const_defined?(class_name)
        Object.send(:remove_const, class_name)
      end
    end
  end

  it 'works with rake' do
    fn = make_file("90")

    task = Cane::RakeTask.new(:quality) do |cane|
      cane.no_abc = true
      cane.no_doc = true
      cane.no_style = true
      cane.add_threshold fn, :>=, 99
    end

    task.no_abc.should == true

    task.should_receive(:abort)
    out = capture_stdout do
      Rake::Task['quality'].invoke
    end

    out.should include("Quality threshold crossed")
  end

  it 'rake works with user-defined check' do
    my_check = Class.new(Struct.new(:opts)) do
      def violations
        [description: 'test', label: opts.fetch(:some_opt)]
      end
    end

    task = Cane::RakeTask.new(:quality) do |cane|
      cane.no_abc = true
      cane.no_doc = true
      cane.no_style = true
      cane.use my_check, some_opt: "theopt"
    end

    task.should_receive(:abort)
    out = capture_stdout do
      Rake::Task['quality'].invoke
    end

    out.should include("theopt")
  end

  after do
    Rake::Task.clear
  end
end
