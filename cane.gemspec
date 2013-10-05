# -*- encoding: utf-8 -*-
require File.expand_path('../lib/cane/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Xavier Shay"]
  gem.email         = ["xavier@squareup.com"]
  gem.description   =
    %q{Fails your build if code quality thresholds are not met}
  gem.summary       = %q{
    Fails your build if code quality thresholds are not met. Provides
    complexity and style checkers built-in, and allows integration with with
    custom quality metrics.
  }
  gem.homepage      = "http://github.com/square/cane"

  gem.executables   = []
  gem.required_ruby_version = '>= 1.9.0'
  gem.files         = Dir.glob("{spec,lib}/**/*.rb") + %w(
                        README.md
                        HISTORY.md
                        LICENSE
                        cane.gemspec
                      )
  gem.test_files    = Dir.glob("spec/**/*.rb")
  gem.name          = "cane"
  gem.require_paths = ["lib"]
  gem.bindir        = "bin"
  gem.executables  << "cane"
  gem.license       = "Apache 2.0"
  gem.version       = Cane::VERSION
  gem.has_rdoc      = false
  gem.add_dependency 'parallel'
  gem.add_development_dependency 'rspec', '~> 2.0'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'rspec-fire'
end
