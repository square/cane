#!/usr/bin/env rake
require "bundler/gem_tasks"

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
rescue LoadError
  $stderr.puts "rspec not available, spec task not provided"
end

desc "Run cane to check quality metrics"
task :quality do
  puts `bin/cane`
  exit $?.exitstatus unless $?.exitstatus == 0
end

task :default => :quality
