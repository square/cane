require 'cane/runner'
require 'cane/version'

require 'cane/cli/parser'

module Cane
  # Command line interface. This passes off arguments to the parser and starts
  # the Cane runner
  module CLI
    def run(args)
      spec = Parser.parse(args)
      if spec.is_a?(Hash)
        Cane.run(spec)
      else
        spec
      end
    end
    module_function :run

  end
end
