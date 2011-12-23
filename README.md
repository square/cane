# Cane

> Discipline will set you free.

Fails your build if code quality thresholds are not met.

## Usage

Add `cane` to your `Gemfile`:

    gem 'cane'

Then add a task to your `Rakefile`:

    task :quality do
      Cane.run(
        style:    { files: '{lib,spec}/**/*.rb' },
        abc:      { files: 'lib/**/*.rb', max: 12, avg: 6 },
        coverage: { min: 95 }
      )

    end

Your main build task should depend or run this task. It will have a non-zero
exit code if any quality checks fail. Also, a report:

    > rake cane

    Methods exceeded maximum allowed ABC complexity:

      lib/cane.rb:52   Cane#sample    13
      lib/cane.rb:73   Cane#sample_2  13

    Lines violated style requirements:

      lib/cane.rb:20   Line length >80
      lib/cane.rb:42   Trailing whitespace

    Minimum code coverage exceeded:

      90% < 92%
