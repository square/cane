require 'tempfile'

require 'xspec'

extend XSpec.dsl(
  notifier: XSpec::Notifier::ColoredDocumentation.new +
            XSpec::Notifier::TimingsAtEnd.new +
            XSpec::Notifier::FailuresAtEnd.new
)

autorun!

# Keep a reference to all tempfiles so they are not garbage collected until the
# process exits.
$tempfiles = []

def make_file(content)
  tempfile = Tempfile.new('cane')
  $tempfiles << tempfile
  tempfile.print(content)
  tempfile.flush
  tempfile.path
end

def in_tmp_dir(&block)
  Dir.mktmpdir do |dir|
    Dir.chdir(dir, &block)
  end
end

# TODO: Port to xspec
  def assert_equal(expected, actual)
    assert expected == actual, <<-EOS


    want: #{expected}
     got: #{actual}

EOS
  end
