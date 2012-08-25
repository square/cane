require 'cane'
require 'cane/version'

require 'cane/cli/spec'

module Cane
  module CLI
    def run(args)
      spec = Spec.new.parse(args)
      if spec.is_a?(Hash)
        Cane.run(spec)
      else
        spec
      end
    end
    module_function :run

  end
end
