# Cane

> Discipline will set you free.

Fails your build if code quality thresholds are not met.

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

    Minimum code coverage exceeded:

      90% < 92%
