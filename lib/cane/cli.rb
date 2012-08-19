require 'cane'
require 'cane/version'

require 'cane/cli/spec'
require 'cane/cli/translator'

module Cane
  module CLI
    def run(args)
      opts = Spec.new.parse(args)
      if opts
        Cane.run(opts, Spec::CHECKS)
      else
        true
      end
    end
    module_function :run

  end
end
