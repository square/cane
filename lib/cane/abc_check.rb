require 'ripper'

require 'cane/abc_max_violation'

# Borrowed heavily from metric_abc
class AbcCheck < Struct.new(:opts)
  def violations
    Dir[opts.fetch(:files)].map do |file_name|
      @ast        = Ripper::SexpBuilder.new(File.read(file_name)).parse
      @complexity = {}
      @nesting    = []
      process_ast(@ast)
      @complexity.map do |x|
        AbcMaxViolation.new(file_name, x.first, x.last) if x.last > opts.fetch(:max)
      end.compact
    end.flatten.sort_by(&:complexity).reverse
  end

  def process_ast(node)
    backup_nesting = @nesting.clone

    if node[0] == :def
      @nesting << node[1][1]
      @complexity[@nesting.join(" > ")] = calculate_abc(node)
    elsif node[0] == :class || node[0] == :module
      if node[1][1][1].is_a? Symbol
        @nesting << node[1][1][1]
      else
        @nesting << node[1][-1][1]
      end
    end

    node[1..-1].each { |n| process_ast(n) if n } if node.is_a? Array
    @nesting = backup_nesting
  end

  def calculate_abc(method_node)
    a = calculate_assignments(method_node)
    b = calculate_branches(method_node)
    c = calculate_conditions(method_node)
    abc = Math.sqrt(a**2 + b**2 + c**2).round
    abc
  end

  def calculate_assignments(node)
    node.flatten.select{|n| [:assign, :opassign].include?(n)}.size.to_f
  end

  def calculate_branches(node)
    node.flatten.select{|n| [:call, :fcall, :brace_block, :do_block].include?(n)}.size.to_f + 1.0
  end

  def calculate_conditions(node, sum=0)
    node.flatten.select{|n| [:==, :===, :"<>", :"<=", :">=", :"=~", :>, :<, :else, :"<=>"].include?(n)}.size.to_f
  end
end
