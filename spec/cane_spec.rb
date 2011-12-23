require 'spec_helper'

require 'cane'

describe 'Cane' do
  it 'fails if ABC metric does not meet requirements' do
    file_name = make_file(<<-RUBY)
      class Harness
        def complex_method(a)
          if a < 2
            return "low"
          else
            return "high"
          end
        end
      end
    RUBY

    Cane.run(
      abc: { files: file_name, max: 1 },
      out: StringIO.new
    ).should_not be
  end

  it 'passes if ABC metric meets requirements' do
    file_name = make_file(<<-RUBY)
      def complex_method(a)
        if a < 2
          return "low"
        else
          return "high"
        end
      end
    RUBY

    Cane.run(
      abc: { files: file_name, max: 2 },
      out: StringIO.new
    ).should be
  end
end
