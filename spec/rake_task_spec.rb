require 'spec_helper'

require 'cane/rake_task'

describe Cane::RakeTask do
  it 'enables cane to be configured an run via rake' do
    fn = make_file("90")
    my_check = Class.new(Struct.new(:opts)) do
      def violations
        [description: 'test', label: opts.fetch(:some_opt)]
      end
    end

    task = Cane::RakeTask.new(:quality) do |cane|
      cane.no_abc = true
      cane.no_doc = true
      cane.no_style = true
      cane.add_threshold fn, :>=, 99
      cane.use my_check, some_opt: "theopt"
      cane.max_violations = 0
      cane.parallel = false
    end

    task.no_abc.should == true

    task.should_receive(:abort)
    out = capture_stdout do
      Rake::Task['quality'].invoke
    end

    out.should include("Quality threshold crossed")
    out.should include("theopt")
  end

  it 'can be configured using a .cane file' do
    fn = make_file("90").strip

    task = Cane::RakeTask.new(:canefile_quality) do |cane|
      conf = "--gte #{fn},99"
      cane.canefile = make_file(conf)
    end

    task.should_receive(:abort)
    out = capture_stdout do
      Rake::Task['canefile_quality'].invoke
    end

    out.should include("Quality threshold crossed")
  end

  after do
    Rake::Task.clear
  end
end
