require 'cane'
require 'cane/version'

require 'cane/cli/spec'

module Cane
  module CLI
    def run(args)
      opts = Spec.new.parse(args)
      if opts.is_a?(Hash)
        Cane.run(opts, Spec::CHECKS)
      else
        opts
      end
    end
    module_function :run

  end
end
