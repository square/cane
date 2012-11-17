require 'set'

require 'cane/file'
require 'cane/task_runner'

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
        style_glob:    ['Glob to run style checks over',
                           default:  '{app,lib,spec}/**/*.rb',
                           variable: 'GLOB',
                           clobber:  :no_style],
        style_measure: ['Max line length',
                           default: 80,
                           cast:    :to_i,
                           clobber: :no_style],
        style_exclude: ['Exclude file or glob from style checking',
                         variable: 'GLOB',
                         type: Array,
                         default: [],
                         clobber: :no_style],
        no_style:      ['Disable style checking', cast: ->(x) { !x }]
      }
    end

    def violations
      return [] if opts[:no_style]

      worker.map(file_list) do |file_path|
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
      Dir[opts.fetch(:style_glob)].reject {|f| excluded?(f) }
    end

    def measure
      opts.fetch(:style_measure)
    end

    def map_lines(file_path, &block)
      Cane::File.iterator(file_path).map.with_index(&block)
    end

    def exclusions
      @exclusions ||= opts.fetch(:style_exclude, []).flatten.map do |i|
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
