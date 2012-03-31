require 'ripper'

require 'cane/abc_max_violation'
require 'cane/syntax_violation'

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
      ast = Ripper::SexpBuilder.new(File.open(file_name, 'r:utf-8').read).parse
      case ast
      when nil
        InvalidAst.new(file_name)
      else
        RubyAst.new(file_name, max_allowed_complexity, ast)
      end.violations
    end

    # Null object for when the file cannot be parsed.
    class InvalidAst < Struct.new(:file_name)
      def violations
        [SyntaxViolation.new(file_name)]
      end
    end

    # Wrapper object around sexps returned from ripper.
    class RubyAst < Struct.new(:file_name, :max_allowed_complexity, :sexps)
      def violations
        process_ast(sexps).
          select { |nesting, complexity| complexity > max_allowed_complexity }.
          map { |x| AbcMaxViolation.new(file_name, x.first, x.last) }
      end

      protected

      # Recursive function to process an AST. The `complexity` variable mutates,
      # which is a bit confusing. `nesting` does not.
      def process_ast(node, complexity = {}, nesting = [])
        if method_nodes.include?(node[0])
          nesting = nesting + [label_for(node)]
          complexity[nesting.join(" > ")] = calculate_abc(node)
        elsif container_nodes.include?(node[0])
          parent  = node[1][-1][1]
          nesting = nesting + [parent]
        end

        if node.is_a? Array
          node[1..-1].each { |n| process_ast(n, complexity, nesting) if n }
        end
        complexity
      end

      def calculate_abc(method_node)
        a = count_nodes(method_node, assignment_nodes)
        b = count_nodes(method_node, branch_nodes) + 1
        c = count_nodes(method_node, condition_nodes)
        abc = Math.sqrt(a**2 + b**2 + c**2).round
        abc
      end

      def label_for(node)
        # A default case is deliberately omitted since I know of no way this
        # could fail and want it to fail fast.
        node.detect {|x|
          [:@ident, :@op, :@kw, :@const, :@backtick].include?(x[0])
        }[1]
      end

      def count_nodes(node, types)
        node.flatten.select { |n| types.include?(n) }.length
      end

      def assignment_nodes
        [:assign, :opassign]
      end

      def method_nodes
        [:def, :defs]
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

    def file_names
      Dir[opts.fetch(:files)]
    end

    def order(result)
      result.sort_by(&:sort_index).reverse
    end

    def max_allowed_complexity
      opts.fetch(:max)
    end
  end
end
