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

    expect(task.no_abc).to eq(true)

    expect(task).to receive(:abort)
    out = capture_stdout do
      Rake::Task['quality'].invoke
    end

    expect(out).to include("Quality threshold crossed")
    expect(out).to include("theopt")
  end

  it 'can be configured using a .cane file' do
    conf = "--gte 90,99"

    task = Cane::RakeTask.new(:canefile_quality) do |cane|
      cane.canefile = make_file(conf)
    end

    expect(task).to receive(:abort)
    out = capture_stdout do
      Rake::Task['canefile_quality'].invoke
    end

    expect(out).to include("Quality threshold crossed")
  end

  it 'defaults to using a canefile without a block' do
    in_tmp_dir do
      conf = "--gte 90,99"
      conf_file = File.open('.cane', 'w') {|f| f.write conf }

      task = Cane::RakeTask.new(:canefile_quality)

      expect(task).to receive(:abort)
      out = capture_stdout do
        Rake::Task['canefile_quality'].invoke
      end

      expect(out).to include("Quality threshold crossed")
    end
  end

  after do
    Rake::Task.clear
  end
end
