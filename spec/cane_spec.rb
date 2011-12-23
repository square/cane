require 'spec_helper'

describe 'Cane' do
  def run(args)
    cane_bin = File.expand_path("../../bin/cane", __FILE__)
    `#{cane_bin} #{args}`
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
    file_name = make_file(<<-RUBY)
      class A_Harness
      end
    RUBY

    output = run("--style-glob #{file_name}")
    $?.exitstatus.should == 1
    output.should include("Lines violated style requirements")
  end
end
