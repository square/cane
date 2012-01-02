require 'cane'
require 'cane/version'

require 'cane/cli/spec'
require 'cane/cli/translator'

module Cane
  module CLI

    def run(args)
      Cane.run(Spec.new.parse(args))
    end
    module_function :run

  end
end
