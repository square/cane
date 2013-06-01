require 'cane/default_checks'

module Cane
  # Default options for command line interface
  module CLI
    def defaults(check)
      check.options.each_with_object({}) {|(k, v), h|
        option_opts = v[1] || {}
        if option_opts[:type] == Array
          h[k] = []
        else
          h[k] = option_opts[:default]
        end
      }
    end
    module_function :defaults

    def default_options
      {
        max_violations:  0,
        parallel:        false,
        exclusions_file: nil,
        checks:          Cane.default_checks
      }.merge(Cane.default_checks.inject({}) {|a, check|
        a.merge(defaults(check))
      })
    end
    module_function :default_options
  end
end
