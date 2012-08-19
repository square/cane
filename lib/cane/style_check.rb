require 'set'

require 'cane/file'

module Cane

  # Creates violations for files that do not meet style conventions. Only
  # highly obvious, probable, and non-controversial checks are performed here.
  # It is not the goal of the tool to provide an extensive style report, but
  # only to prevent stupid mistakes.
  class StyleCheck < Struct.new(:opts)

    def self.key; :style; end
    def self.name; "style checking"; end
    def self.options
      {
        glob:    ['Glob to run style checks over', '{app,lib,spec}/**/*.rb'],
        measure: ['Max line length', '80', :to_i]
      }
    end

    def violations
      file_list.map do |file_path|
        map_lines(file_path) do |line, line_number|
          violations_for_line(line.chomp).map {|message| {
            file:        file_path,
            line:        line_number + 1,
            label:       message,
            description: "Lines violated style requirements"
          }}
        end
      end.flatten
    end

    protected

    def violations_for_line(line)
      result = []
      if line.length > measure
        result << "Line is >%i characters (%i)" % [measure, line.length]
      end
      result << "Line contains trailing whitespace" if line =~ /\s$/
      result << "Line contains hard tabs"           if line =~ /\t/
      result
    end

    def file_list
      Dir[opts.fetch(:glob)].reject {|f| excluded?(f) }
    end

    def measure
      opts.fetch(:measure)
    end

    def map_lines(file_path, &block)
      Cane::File.iterator(file_path).map_with_index(&block)
    end

    def exclusions
      @exclusions ||= opts.fetch(:exclusions, []).to_set
    end

    def excluded?(file)
      exclusions.include?(file)
    end
  end

end
