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

      lib/cane.rb  Cane > sample    23
      lib/cane.rb  Cane > sample_2  17

    Lines violated style requirements (2):

      lib/cane.rb:20   Line length >80
      lib/cane.rb:42   Trailing whitespace

    Classes are not documented (1):
      lib/cane:3  SomeClass

Customize behaviour with a wealth of options:

    > cane --help
    Usage: cane [options]
            --abc-glob GLOB              Glob to run ABC metrics over (default: lib/**/*.rb)
            --abc-max VALUE              Report any methods with complexity greater than VALUE (default: 15)
            --no-abc                     Disable ABC checking

            --style-glob GLOB            Glob to run style metrics over (default: {lib,spec}/**/*.rb)
            --style-measure VALUE        Max line length (default: 80)
            --no-style                   Disable style checking

            --doc-glob GLOB              Glob to run documentation metrics over (default: lib/**/*.rb)
            --no-doc                     Disable documentation checking

            --gte FILE,THRESHOLD         If FILE contains a single number, verify it is >= to THRESHOLD.

            --max-violations VALUE       Max allowed violations (default: 0)

            --version                    Show version
        -h, --help                       Show this message

## Adding to a legacy project

Cane can be configured to still pass in the presence of a set number of
violations using the `--max-violations` option. This is ideal for retrofitting
on to an existing application that may already have many violations. By setting
the maximum to the current number, no immediate changes will be required to
your existing code base, but you will be protected from things getting worse.

## Integrating with SimpleCov

Any value in a file can be used as a threshold:

    > echo "89" > coverage/covered_percent
    > cane --gte 'coverage/covered_percent,90'

    Quality threshold crossed

      coverage/covered_percent is 89, should be >= 90

You can use a `SimpleCov` formatter to create the required file:

    class SimpleCov::Formatter::QualityFormatter
      def format(result)
        SimpleCov::Formatter::HTMLFormatter.new.format(result)
        File.open("coverage/covered_percent", "w") do |f|
          f.puts result.source_files.covered_percent.to_f
        end
      end
    end

    SimpleCov.formatter = SimpleCov::Formatter::QualityFormatter

## Compatibility

Requires MRI 1.9, since it depends on the `ripper` library to calculate
complexity metrics. This only applies to the Ruby used to run Cane, not the
project it is being run against. In other words, you can run Cane against your
1.8 project.

## Support

[Ask questions on Stack
Overflow](http://stackoverflow.com/questions/ask?tags=ruby+cane). We keep an
eye on new cane questions.

## Contributing

Fork and patch! Before any changes are merged to master, we need you to sign an
[Individual Contributor
Agreement](https://spreadsheets.google.com/a/squareup.com/spreadsheet/viewform?formkey=dDViT2xzUHAwRkI3X3k5Z0lQM091OGc6MQ&ndplr=1)
(Google Form).
