require 'cane/file'
require 'cane'

module Cane

  # Creates violations for class definitions that do not have an explantory
  # comment immediately preceeding.
  class DocCheck < Struct.new(:opts)

    DESCRIPTION =
      "Class definitions require explanatory comments on preceeding line"

    def self.key; :doc; end
    def self.name; "documentation checking"; end
    def self.options
      {
        doc_glob:  ['Glob to run doc checks over',
                       default:  '{app,lib}/**/*.rb',
                       variable: 'GLOB',
                       clobber:  :no_doc],
        no_readme: ['Disable readme checking', cast: ->(x) { !x }],
        no_doc:    ['Disable documentation checking', cast: ->(x) { !x }]
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
      unless opts[:no_readme]
        unless ['', '.txt', '.md'].any? {|x| Cane::File.exists?("README#{x}") }
          result << {
            description: 'Missing documentation',
            label:       'No README found'
          }
        end
      end
      result
    end

    def file_names
      Dir[opts.fetch(:doc_glob)]
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

    def worker
      Cane.task_runner(opts)
    end
  end

end
