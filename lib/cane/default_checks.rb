require 'cane/abc_check'
require 'cane/style_check'
require 'cane/doc_check'
require 'cane/threshold_check'

module Cane
  def default_checks
    [
      AbcCheck,
      StyleCheck,
      DocCheck,
      ThresholdCheck
    ]
  end
  module_function :default_checks
end
