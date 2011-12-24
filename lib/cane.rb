require 'cane/abc_check'
require 'cane/style_check'
require 'cane/violation_formatter'

module Cane
  def run(opts)
    out = opts.fetch(:out, $stdout)

    violations = {
      abc:   AbcCheck,
      style: StyleCheck
    }.map {|key, check|
      if opts[key]
        check.new(opts[key]).violations
      else
        []
      end
    }.flatten

    if violations.any?
      out.puts ViolationFormatter.new(violations).to_s
      false
    else
      true
    end
  end
  module_function :run
end
