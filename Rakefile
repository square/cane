#!/usr/bin/env rake
require "bundler/gem_tasks"
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
rescue LoadError
  warn "rspec not available, spec task not provided"
end

begin
  require 'cane/rake_task'

  desc "Run cane to check quality metrics"
  Cane::RakeTask.new(:quality) do |cane|
    cane.abc_max = 10
    cane.add_threshold 'coverage/covered_percent', :>=, 99
  end

  task :default => :quality
rescue LoadError
  warn "cane not available, quality task not provided."
end
