require 'cane/default_checks'

module Cane
  module CLI
    def defaults(check)
      x = check.options.each_with_object({}) {|(k, v), h|
        h[k] = (v[1] || {})[:default]
      }
      x
    end
    module_function :defaults

    OPTIONS = {
      max_violations:  0,
      exclusions_file: nil,
    }.merge(Cane::DEFAULT_CHECKS.inject({}) {|a, check|
      a.merge(defaults(check))
    })
  end
end
