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
        if x.last > opts.fetch(:max)
          AbcMaxViolation.new(file_name, x.first, x.last)
        end
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
    a = count_nodes(method_node, assignment_nodes)
    b = count_nodes(method_node, branch_nodes) + 1
    c = count_nodes(method_node, condition_nodes)
    abc = Math.sqrt(a**2 + b**2 + c**2).round
    abc
  end

  def assignment_nodes
    [:assign, :opassign]
  end

  def count_nodes(node, types)
    node.flatten.select { |n| types.include?(n) }.size.to_f
  end

  def branch_nodes
    [:call, :fcall, :brace_block, :do_block]
  end

  def condition_nodes
    [:==, :===, :"<>", :"<=", :">=", :"=~", :>, :<, :else, :"<=>"]
  end
end
