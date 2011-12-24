# Cane

Fails your build if code quality thresholds are not met.

> Discipline will set you free.

## Usage

    gem install cane
    cane --abc-glob '{lib,spec}/**/*.rb' --abc-max 15

Your main build task should run this, probably via `bundle exec`. It will have
a non-zero exit code if any quality checks fail. Also, a report:

    > cane

    Methods exceeded maximum allowed ABC complexity:

      lib/cane.rb  Cane > sample    23
      lib/cane.rb  Cane > sample_2  17

    Lines violated style requirements:

      lib/cane.rb:20   Line length >80
      lib/cane.rb:42   Trailing whitespace

Customize behaviour with a wealth of options:

    > cane --help
    Usage:   cane [options]
    Example: cane --no-style --abc-glob 'lib/**/*.rb'

            --abc-glob GLOB              Glob to run ABC metrics over (default: lib/**/*.rb)
            --abc-max MAX                Maximum allowed ABC complexity (default: 15)
            --no-abc                     Disable ABC checking

            --style-glob GLOB            Glob to run style metrics over (default: lib/**/*.rb)
            --no-style                   Disable style checking

            --gte FILE,THRESHOLD         If FILE contains a single number, verify it is >= to THRESHOLD.

        -h, --help                       Show this message
            --version                    Show version

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
