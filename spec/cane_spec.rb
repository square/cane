require 'spec_helper'
require "stringio"
require 'cane/cli'

require 'cane/rake_task'

# Acceptance tests
describe 'The cane application' do
  let(:class_name) { "C#{rand(10 ** 10)}" }

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

    output, exitstatus = run %(
      --style-glob #{fn}
      --doc-glob #{fn}
      --abc-glob #{fn}
      --abc-max 1
      -r #{check_file}
      --check #{class_name}
      --unhappy-file #{fn}
    )
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

  after do
    if Object.const_defined?(class_name)
      Object.send(:remove_const, class_name)
    end
  end

  def run(cli_args)
    result = nil
    output = capture_stdout do
      result = Cane::CLI.run(
        %w(--no-abc --no-style --no-doc) + cli_args.split(/\s+/m)
      )
    end

    [output, result ? 0 : 1]
  end
end
