require 'ripper'

require 'cane/abc_max_violation'

module Cane

  # Creates violations for methods that are too complicated using a simple
  # algorithm run against the parse tree of a file to count assignments,
  # branches, and conditionals. Borrows heavily from metric_abc.
  class AbcCheck < Struct.new(:opts)
    def violations
      order file_names.map { |file_name|
        find_violations(file_name)
      }.flatten
    end

    protected

    def find_violations(file_name)
      ast = sexps_from_file(file_name)

      process_ast(ast).
        select { |nesting, complexity| complexity > max_allowed_complexity }.
        map { |x| AbcMaxViolation.new(file_name, x.first, x.last) }
    end

    # Recursive function to process an AST. The `complexity` variable mutates,
    # which is a bit confusing. `nesting` does not.
    def process_ast(node, complexity = {}, nesting = [])
      if method_nodes.include?(node[0])
        nesting = nesting + [node[1][1]]
        complexity[nesting.join(" > ")] = calculate_abc(node)
      elsif container_nodes.include?(node[0])
        parent = if node[1][1][1].is_a?(Symbol)
          node[1][1][1]
        else
          node[1][-1][1]
        end
        nesting = nesting + [parent]
      end

      if node.is_a? Array
        node[1..-1].each { |n| process_ast(n, complexity, nesting) if n }
      end
      complexity
    end

    def sexps_from_file(file_name)
      Ripper::SexpBuilder.new(File.open(file_name, 'r:utf-8').read).parse
    end

    def max_allowed_complexity
      opts.fetch(:max)
    end

    def calculate_abc(method_node)
      a = count_nodes(method_node, assignment_nodes)
      b = count_nodes(method_node, branch_nodes) + 1
      c = count_nodes(method_node, condition_nodes)
      abc = Math.sqrt(a**2 + b**2 + c**2).round
      abc
    end

    def count_nodes(node, types)
      node.flatten.select { |n| types.include?(n) }.length
    end

    def file_names
      Dir[opts.fetch(:files)]
    end

    def order(result)
      result.sort_by(&:complexity).reverse
    end

    def assignment_nodes
      [:assign, :opassign]
    end

    def method_nodes
      [:def]
    end

    def container_nodes
      [:class, :module]
    end

    def branch_nodes
      [:call, :fcall, :brace_block, :do_block]
    end

    def condition_nodes
      [:==, :===, :"<>", :"<=", :">=", :"=~", :>, :<, :else, :"<=>"]
    end
  end
end
