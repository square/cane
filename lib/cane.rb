require 'abc_check'

class Cane
  def self.run(opts)
    out = opts.fetch(:out, $stdout)

    abc = opts.fetch(:abc)
    violations = AbcCheck.new(abc).violations

    if violations.any?
      violations.each do |v|
        out.puts(v.to_s)
      end
      false
    else
      true
    end
  end
end
