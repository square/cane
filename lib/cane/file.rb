require 'cane/encoding_aware_iterator'

module Cane

  # An interface for interacting with files that ensures encoding is handled in
  # a consistent manner.
  class File
    class << self
      def iterator(path)
        EncodingAwareIterator.new(open(path).each_line)
      end

      def contents(path)
        open(path).read
      end

      def open(path)
        ::File.open(path, 'r:utf-8')
      end

      def exists?(path)
        ::File.exists?(path)
      end

      def case_insensitive_glob(glob)
        Dir.glob(glob, ::File::FNM_CASEFOLD)
      end
    end
  end
end
