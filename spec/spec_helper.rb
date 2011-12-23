require 'tempfile'

def make_file(content)
  tempfile = Tempfile.new('cane')
  tempfile.print(content)
  tempfile.flush
  tempfile.path
end
