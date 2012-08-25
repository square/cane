# Fake check for use in specs
class UnhappyCheck < Struct.new(:opts)
  def self.options
    {
      unhappy_file: ["File to check", default: [nil]]
    }
  end

  def violations
    [
      description: "Files are unhappy",
      file:        opts.fetch(:unhappy_file),
      label:       ":("
    ]
  end
end
