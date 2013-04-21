require 'spec_helper'
require 'tmpdir'

require 'cane/file'

describe Cane::File do
  describe '.case_insensitive_glob' do
    it 'matches all kinds of readmes' do
      expected = %w(
        README
        readme.md
        ReaDME.TEXTILE
      )

      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          expected.each do |x|
            FileUtils.touch(x)
          end
          Cane::File.case_insensitive_glob("README*").should =~ expected
        end
      end
    end
  end
end
