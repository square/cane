require 'cane'
require 'cane/version'

require 'cane/cli/parser'

module Cane
  module CLI
    def run(args)
      spec = Parser.new.parse(args)
      if spec.is_a?(Hash)
        Cane.run(spec)
      else
        spec
      end
    end
    module_function :run

  end
end
