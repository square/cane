require 'abc_check'
require 'cane/violation_formatter'

module Cane
  def run(opts)
    out = opts.fetch(:out, $stdout)

    abc = opts.fetch(:abc)
    violations = AbcCheck.new(abc).violations

    if violations.any?
      out.puts ViolationFormatter.new(violations).to_s
      false
    else
      true
    end
  end
  module_function :run
end
