require 'ripper'
require 'set'

require 'cane/file'
require 'cane/task_runner'

module Cane

  # Creates violations for methods that are too complicated using a simple
  # algorithm run against the parse tree of a file to count assignments,
  # branches, and conditionals. Borrows heavily from metric_abc.
  class AbcCheck < Struct.new(:opts)

    def self.key; :abc; end
    def self.name; "ABC check"; end
    def self.options
      {
        abc_glob: ['Glob to run ABC metrics over',
                      default: '{app,lib}/**/*.rb',
                      variable: 'GLOB',
                      clobber: :no_abc],
        abc_max:  ['Ignore methods under this complexity',
                      default: 15,
                      cast:    :to_i,
                      clobber: :no_abc],
        abc_exclude: ['Exclude method from analysis (eg. Foo::Bar#method)',
                         variable: 'METHOD',
                         type: Array,
                         default: [],
                         clobber: :no_abc],
        no_abc:   ['Disable ABC checking',
                      cast: ->(x) { !x }]
      }
    end

    def violations
      return [] if opts[:no_abc]

      order worker.map(file_names) {|file_name|
        find_violations(file_name)
      }.flatten
    end

    protected

    def find_violations(file_name)
      ast = Ripper::SexpBuilder.new(Cane::File.contents(file_name)).parse
      case ast
      when nil
        InvalidAst.new(file_name)
      else
        RubyAst.new(file_name, max_allowed_complexity, ast, exclusions)
      end.violations
    end

    # Null object for when the file cannot be parsed.
    class InvalidAst < Struct.new(:file_name)
      def violations
        [{file: file_name, description: "Files contained invalid syntax"}]
      end
    end

    # Wrapper object around sexps returned from ripper.
    class RubyAst < Struct.new(:file_name, :max_allowed_complexity,
                               :sexps, :exclusions)

      def initialize(*args)
        super
        self.anon_method_add = true
      end

      def violations
        process_ast(sexps).
          select {|nesting, complexity| complexity > max_allowed_complexity }.
          map {|x| {
            file:        file_name,
            label:       x.first,
            value:       x.last,
            description: "Methods exceeded maximum allowed ABC complexity"
          }}
      end

      protected

      # Stateful flag used to determine whether we are currently parsing an
      # anonymous class. See #container_label.
      attr_accessor :anon_method_add

      # Recursive function to process an AST. The `complexity` variable mutates,
      # which is a bit confusing. `nesting` does not.
      def process_ast(node, complexity = {}, nesting = [])
        if method_nodes.include?(node[0])
          nesting = nesting + [label_for(node)]
          desc = method_description(node, *nesting)
          unless excluded?(desc)
            complexity[desc] = calculate_abc(node)
          end
        elsif parent = container_label(node)
          nesting = nesting + [parent]
        end

        if node.is_a? Array
          node[1..-1].each {|n| process_ast(n, complexity, nesting) if n }
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

      def container_label(node)
        if container_nodes.include?(node[0])
          # def foo, def self.foo
          node[1][-1][1]
        elsif node[0] == :method_add_block
          if anon_method_add
            # Class.new do ...
            "(anon)"
          else
            # MyClass = Class.new do ...
            # parent already added when processing a parent node
            anon_method_add = true
            nil
          end
        elsif node[0] == :assign && node[2][0] == :method_add_block
          # MyClass = Class.new do ...
          self.anon_method_add = false
          node[1][-1][1]
        end
      end

      def label_for(node)
        # A default case is deliberately omitted since I know of no way this
        # could fail and want it to fail fast.
        node.detect {|x|
          [:@ident, :@op, :@kw, :@const, :@backtick].include?(x[0])
        }[1]
      end

      def count_nodes(node, types)
        node.flatten.select {|n| types.include?(n) }.length
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

      METH_CHARS = { def: '#', defs: '.' }

      def excluded?(method_description)
        exclusions.include?(method_description)
      end

      def method_description(node, *modules, meth_name)
        separator = METH_CHARS.fetch(node.first)
        description = [modules.join('::'), meth_name].join(separator)
      end
    end

    def file_names
      Dir[opts.fetch(:abc_glob)]
    end

    def order(result)
      result.sort_by {|x| x[:value].to_i }.reverse
    end

    def max_allowed_complexity
      opts.fetch(:abc_max)
    end

    def exclusions
      opts.fetch(:abc_exclude, []).flatten.to_set
    end

    def worker
      Cane.task_runner(opts)
    end
  end
end
