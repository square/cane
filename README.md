# Cane

Fails your build if code quality thresholds are not met.

> Discipline will set you free.

## Usage

    gem install cane
    cane --abc-glob '{lib,spec}/**/*.rb' --abc-max 15

Your main build task should run this, probably via `bundle exec`. It will have
a non-zero exit code if any quality checks fail. Also, a report:

    > cane

    Methods exceeded maximum allowed ABC complexity (2):

      lib/cane.rb  Cane#sample    23
      lib/cane.rb  Cane#sample_2  17

    Lines violated style requirements (2):

      lib/cane.rb:20   Line length >80
      lib/cane.rb:42   Trailing whitespace

    Class definitions require explanatory comments on preceding line (1):
      lib/cane:3  SomeClass

Customize behaviour with a wealth of options:

    > cane --help
    Usage: cane [options]

    Default options are loaded from a .cane file in the current directory.

    -r, --require FILE               Load a Ruby file containing user-defined checks
    -c, --check CLASS                Use the given user-defined check

        --abc-glob GLOB              Glob to run ABC metrics over (default: {app,lib}/**/*.rb)
        --abc-max VALUE              Ignore methods under this complexity (default: 15)
        --abc-exclude METHOD         Exclude method from analysis (eg. Foo::Bar#method)
        --no-abc                     Disable ABC checking

        --style-glob GLOB            Glob to run style checks over (default: {app,lib,spec}/**/*.rb)
        --style-measure VALUE        Max line length (default: 80)
        --style-exclude GLOB         Exclude file or glob from style checking
        --no-style                   Disable style checking

        --doc-glob GLOB              Glob to run doc checks over (default: {app,lib}/**/*.rb)
        --doc-exclude GLOB           Exclude file or glob from documentation checking
        --no-readme                  Disable readme checking
        --no-doc                     Disable documentation checking

        --lt FILE,THRESHOLD          Check the number in FILE is < to THRESHOLD (a number or another file name)
        --lte FILE,THRESHOLD         Check the number in FILE is <= to THRESHOLD (a number or another file name)
        --eq FILE,THRESHOLD          Check the number in FILE is == to THRESHOLD (a number or another file name)
        --gte FILE,THRESHOLD         Check the number in FILE is >= to THRESHOLD (a number or another file name)
        --gt FILE,THRESHOLD          Check the number in FILE is > to THRESHOLD (a number or another file name)

    -f, --all FILE                   Apply all checks to given file
        --max-violations VALUE       Max allowed violations (default: 0)
        --json                       Output as JSON
        --parallel                   Use all processors. Slower on small projects, faster on large.
        --color                      Colorize output

    -v, --version                    Show version
    -h, --help                       Show this message

Set default options using a `.cane` file:

    > cat .cane
    --no-doc
    --abc-glob **/*.rb
    > cane

It works exactly the same as specifying the options on the command-line.
Command-line arguments will override arguments specified in the `.cane` file.

## Integrating with Rake

```ruby
begin
  require 'cane/rake_task'

  desc "Run cane to check quality metrics"
  Cane::RakeTask.new(:quality) do |cane|
    cane.abc_max = 10
    cane.add_threshold 'coverage/covered_percent', :>=, 99
    cane.no_style = true
    cane.abc_exclude = %w(Foo::Bar#some_method)
  end

  task :default => :quality
rescue LoadError
  warn "cane not available, quality task not provided."
end
```

Loading options from a `.cane` file is supported by setting `canefile=` to the
file name.

Rescuing `LoadError` is a good idea, since `rake -T` failing is totally
frustrating.

## Adding to a legacy project

Cane can be configured to still pass in the presence of a set number of
violations using the `--max-violations` option. This is ideal for retrofitting
on to an existing application that may already have many violations. By setting
the maximum to the current number, no immediate changes will be required to
your existing code base, but you will be protected from things getting worse.

You may also consider beginning with high thresholds and ratcheting them down
over time, or defining exclusions for specific troublesome violations (not
recommended).

## Integrating with SimpleCov

Any value in a file can be used as a threshold:

    > echo "89" > coverage/.last_run.json
    > cane --gte 'coverage/.last_run.json,90'

    Quality threshold crossed

      coverage/covered_percent is 89, should be >= 90

## Implementing your own checks

Checks must implement:

* A class level `options` method that returns a hash of available options. This
  will be included in help output if the check is added before `--help`. If
  your check does not require any configuration, return an empty hash.
* A one argument constructor, into which will be passed the options specified
  for your check.
* A `violations` method that returns an array of violations.

See existing checks for guidance. Create your check in a new file:

```ruby
# unhappy.rb
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
```

Include your check either using command-line options:

    cane -r unhappy.rb --check UnhappyCheck --unhappy-file myfile

Or in your rake task:

```ruby
require 'unhappy'

Cane::RakeTask.new(:quality) do |c|
  c.use UnhappyCheck, unhappy_file: 'myfile'
end
```

## Protips

### Writing class level documentation

Classes are commonly the first entry point into a code base, often for an
oncall engineer responding to an exception, so provide enough information to
orient first-time readers.

A good class level comment should answer the following:

* Why does this class exist?
* How does it fit in to the larger system?
* Explanation of any domain-specific terms.

If you have specific documentation elsewhere (say, in the README or a wiki), a
link to that suffices.

If the class is a known entry point, such as a regular background job that can
potentially fail, then also provide enough context that it can be efficently
dealt with. In the background job case:

* Should it be retried?
* What if it failed 5 days ago and we're only looking at it now?
* Who cares that this job failed?

### Writing a readme

A good README should include at a minimum:

* Why the project exists.
* How to get started with development.
* How to deploy the project (if applicable).
* Status of the project (spike, active development, stable in production).
* Compatibility notes (1.8, 1.9, JRuby).
* Any interesting technical or architectural decisions made on the project
  (this could be as simple as a link to an external design document).

## Compatibility

Requires MRI 1.9, since it depends on the `ripper` library to calculate
complexity metrics. This only applies to the Ruby used to run Cane, not the
project it is being run against. In other words, you can run Cane against your
1.8 or JRuby project.

## Support

Make a [new github issue](https://github.com/square/cane/issues/new).

## Contributing

Fork and patch! Before any changes are merged to master, we need you to sign an
[Individual Contributor
Agreement](https://spreadsheets.google.com/a/squareup.com/spreadsheet/viewform?formkey=dDViT2xzUHAwRkI3X3k5Z0lQM091OGc6MQ&ndplr=1)
(Google Form).
