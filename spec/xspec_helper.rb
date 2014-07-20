require 'tempfile'

require 'xspec'

extend XSpec.dsl(
  assertion_context: XSpec::AssertionContext.stack {
    include XSpec::AssertionContext::Simple
    include XSpec::AssertionContext::Doubles.with(:auto_verify, :strict)
  },
  notifier: XSpec::Notifier::ColoredDocumentation.new +
            XSpec::Notifier::TimingsAtEnd.new +
            XSpec::Notifier::FailuresAtEnd.new
)

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

def capture_stdout
  out = StringIO.new
  $stdout = out
  yield
  return out.string
ensure
  $stdout = STDOUT
end

def assert_no_violations(check)
  assert_equal [], check.violations
end

def assert_violation(label, check)
  violations = check.violations
  assert_equal 1, violations.length
  assert_equal label, violations[0][:label]
end
