require 'cane/abc_check'
require 'cane/style_check'
require 'cane/doc_check'
require 'cane/threshold_check'

module Cane
  DEFAULT_CHECKS = [
    AbcCheck,
    StyleCheck,
    DocCheck,
    ThresholdCheck
  ].freeze
end
