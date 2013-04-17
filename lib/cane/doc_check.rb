require 'cane/file'
require 'cane/task_runner'

module Cane

  # Creates violations for class definitions that do not have an explantory
  # comment immediately preceding.
  class DocCheck < Struct.new(:opts)

    DESCRIPTION =
      "Class definitions require explanatory comments on preceding line"

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

    def violations
      return [] if opts[:no_doc]

      missing_file_violations + worker.map(file_names) {|file_name|
        find_violations(file_name)
      }.flatten
    end

    def find_violations(file_name)
      last_line = ""
      Cane::File.iterator(file_name).map.with_index do |line, number|
        result = if class_definition?(line) && !comment?(last_line)
          {
            file:        file_name,
            line:        number + 1,
            label:       extract_class_name(line),
            description: DESCRIPTION
          }
        end
        last_line = line
        result
      end.compact
    end

    def missing_file_violations
      result = []
      return result if opts[:no_readme]

      filenames = ['README', 'readme']
      extensions = ['', '.txt', '.md', '.mdown', '.rdoc', '.markdown', '.textile']
      combinations = filenames.product(extensions)

      if combinations.none? {|n, x| Cane::File.exists?(n + x) }
        result << { description: 'Missing documentation',
                    label: 'No README found' }
      end
      result
    end

    def file_names
      Dir[opts.fetch(:doc_glob)].reject { |file| excluded?(file) }
    end

    def class_definition?(line)
      line =~ /^\s*class\s+/ and $'.index('<<') != 0
    end

    def comment?(line)
      line =~ /^\s*#/ && !(MAGIC_COMMENT_REGEX =~ line)
    end

    def extract_class_name(line)
      line.match(/class\s+([^\s;]+)/)[1]
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
