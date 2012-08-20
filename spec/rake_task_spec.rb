require 'spec_helper'

require 'cane/rake_task'

describe Cane::RakeTask do
  it 'adds a new threshold' do
    task = described_class.new do |t|
      t.add_threshold 'coverage', :>=, 99
    end

    task.options[:gte].should == [["coverage", 99]]
  end
end
