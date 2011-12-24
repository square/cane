require 'tempfile'

def make_file(content)
  tempfile = Tempfile.new('cane')
  tempfile.print(content)
  tempfile.flush
  tempfile.path
end

require 'simplecov'

class SimpleCov::Formatter::QualityFormatter
  def format(result)
    SimpleCov::Formatter::HTMLFormatter.new.format(result)
    File.open("coverage/covered_percent", "w") do |f|
      f.puts result.source_files.covered_percent.to_i
    end
  end
end

SimpleCov.formatter = SimpleCov::Formatter::QualityFormatter
SimpleCov.start
