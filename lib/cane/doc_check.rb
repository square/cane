module Cane

  # Creates violations for class definitions that do not have an explantory
  # comment immediately preceeding.
  class DocCheck < Struct.new(:opts)
    def violations
      file_names.map { |file_name|
        find_violations(file_name)
      }.flatten
    end

    def find_violations(file_name)
      last_line = ""
      File.open(file_name, 'r:utf-8').lines.map.with_index do |line, number|
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
      Dir[opts.fetch(:files)]
    end

    def class_definition?(line)
      line =~ /^\s*class\s+/ and $'.index('<<') != 0
    end

    def comment?(line)
      line =~ /^\s*#/
    end

    def extract_class_name(line)
      line.match(/class ([^\s;]+)/)[1]
    end
  end

end
