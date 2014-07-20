require 'xspec_helper'

require 'cane/rake_task'

describe Cane::RakeTask do
  it 'enables cane to be configured an run via rake' do
    fn = make_file("90")
    my_check = Class.new(Struct.new(:opts)) do
      def violations
        [description: 'test', label: opts.fetch(:some_opt)]
      end
    end

    out = run_rake do |cane|
      cane.no_abc = true
      cane.no_doc = true
      cane.no_style = true
      cane.add_threshold fn, :>=, 99
      cane.use my_check, some_opt: "theopt"
      cane.max_violations = 0
      cane.parallel = false
    end

    assert_include "Quality threshold crossed", out
    assert_include "theopt", out
  end

  it 'can be configured using a .cane file' do

    out = run_rake do |cane|
      cane.canefile = make_file("--gte 90,99")
    end

    assert_include "Quality threshold crossed", out
  end

  it 'defaults to using a canefile without a block' do
    in_tmp_dir do
      conf = "--gte 90,99"
      conf_file = File.open('.cane', 'w') {|f| f.write conf }

      out = run_rake

      assert_include "Quality threshold crossed", out
    end
  end

  def run_rake(&block)
    Cane::RakeTask.new(:quality, &block)

    capture_stdout do
      begin
        Rake::Task['quality'].invoke
      rescue SystemExit => e
      end
    end
  ensure
    Rake::Task.clear
  end
end
