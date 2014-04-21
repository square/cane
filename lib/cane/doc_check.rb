require 'cane/file'
require 'cane/task_runner'

module Cane

  # Creates violations for class definitions that do not have an explantory
  # comment immediately preceding.
  class DocCheck < Struct.new(:opts)

    DESCRIPTION =
    "Class and Module definitions require explanatory comments on previous line"

    ClassDefinition = Struct.new(:values) do
      def line; values.fetch(:line); end
      def label; values.fetch(:label); end
      def missing_doc?; !values.fetch(:has_doc); end
      def requires_doc?; values.fetch(:requires_doc, false); end
      def requires_doc=(value); values[:requires_doc] = value; end
    end

    def self.key; :doc; end
    def self.name; "documentation checking"; end
    def self.options
      {
        doc_glob:    ['Glob to run doc checks over',
                        default:  '{app,lib}/**/*.rb',
                        variable: 'GLOB',
                        clobber:  :no_doc],
        doc_exclude: ['Exclude file or glob from documentation checking',
                        variable: 'GLOB',
                        type: Array,
                        default: [],
                        clobber: :no_doc],
        no_readme:   ['Disable readme checking', cast: ->(x) { !x }],
        no_doc:      ['Disable documentation checking', cast: ->(x) { !x }]
      }
    end

    # Stolen from ERB source, amended to be slightly stricter to work around
    # some known false positives.
    MAGIC_COMMENT_REGEX =
      %r"#(\s+-\*-)?\s+(en)?coding\s*[=:]\s*([[:alnum:]\-_]+)"

    CLASS_REGEX = /^\s*(?:class|module)\s+([^\s;]+)/

    # http://rubular.com/r/53BapkefdD
    SINGLE_LINE_CLASS_REGEX =
      /^\s*(?:class|module).*;\s*end\s*(#.*)?\s*$/

    METHOD_REGEX = /(?:^|\s)def\s+/

    def violations
      return [] if opts[:no_doc]

      missing_file_violations + worker.map(file_names) {|file_name|
        find_violations(file_name)
      }.flatten
    end

    def find_violations(file_name)
      class_definitions_in(file_name).map do |class_definition|
        if class_definition.requires_doc? && class_definition.missing_doc?
          {
            file:        file_name,
            line:        class_definition.line,
            label:       class_definition.label,
            description: DESCRIPTION
          }
        end
      end.compact
    end

    def class_definitions_in(file_name)
      closed_classes = []
      open_classes = []
      last_line = ""

      Cane::File.iterator(file_name).each_with_index do |line, number|
        if class_definition? line
          if single_line_class_definition? line
            closed_classes
          else
            open_classes
          end.push class_definition(number, line, last_line)

        elsif method_definition?(line) && !open_classes.empty?
          open_classes.last.requires_doc = true
        end

        last_line = line
      end

      (closed_classes + open_classes).sort_by(&:line)
    end

    def class_definition(number, line, last_line)
      ClassDefinition.new({
        line: (number + 1),
        label: extract_class_name(line),
        has_doc: comment?(last_line),
        requires_doc: method_definition?(line)
      })
    end

    def missing_file_violations
      result = []
      return result if opts[:no_readme]

      if Cane::File.case_insensitive_glob("README*").none?
        result << { description: 'Missing documentation',
                    label: 'No README found' }
      end
      result
    end

    def file_names
      Dir[opts.fetch(:doc_glob)].reject { |file| excluded?(file) }
    end

    def method_definition?(line)
      !comment?(line) && line =~ METHOD_REGEX
    end

    def class_definition?(line)
      line =~ CLASS_REGEX && $1.index('<<') != 0
    end

    def single_line_class_definition?(line)
      line =~ SINGLE_LINE_CLASS_REGEX
    end

    def comment?(line)
      line =~ /^\s*#/ && !(MAGIC_COMMENT_REGEX =~ line)
    end

    def extract_class_name(line)
      line.match(CLASS_REGEX)[1]
    end

    def exclusions
      @exclusions ||= opts.fetch(:doc_exclude, []).flatten.map do |i|
        Dir[i]
      end.flatten.to_set
    end

    def excluded?(file)
      exclusions.include?(file)
    end

    def worker
      Cane.task_runner(opts)
    end
  end
end
