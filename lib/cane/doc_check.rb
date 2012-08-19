require 'cane/file'

module Cane

  # Creates violations for class definitions that do not have an explantory
  # comment immediately preceeding.
  class DocCheck < Struct.new(:opts)

    def self.key; :doc; end
    def self.name; "documentation checking"; end
    def self.options
      {
        glob: ['Glob to run doc checks over', '{app,lib}/**/*.rb']
      }
    end

    # Stolen from ERB source.
    MAGIC_COMMENT_REGEX = %r"coding\s*[=:]\s*([[:alnum:]\-_]+)"

    def violations
      file_names.map {|file_name|
        find_violations(file_name)
      }.flatten
    end

    def find_violations(file_name)
      last_line = ""
      Cane::File.iterator(file_name).map_with_index do |line, number|
        result = if class_definition?(line) && !comment?(last_line)
          {
            file:        file_name,
            line:        number + 1,
            label:       extract_class_name(line),
            description: "Classes are not documented"
          }
        end
        last_line = line
        result
      end.compact
    end

    def file_names
      Dir[opts.fetch(:glob)]
    end

    def class_definition?(line)
      line =~ /^\s*class\s+/ and $'.index('<<') != 0
    end

    def comment?(line)
      line =~ /^\s*#/ && !(MAGIC_COMMENT_REGEX =~ line)
    end

    def extract_class_name(line)
      line.match(/class ([^\s;]+)/)[1]
    end
  end

end
