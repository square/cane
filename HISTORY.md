# Cane History

## 1.4.0 - 2 July 2012 (1afc999d)

* Allow files and methods to be whitelisted (#16)
* Show total number of violations in output (#14)

## 1.3.0 - 20 April 2012 (c166dfa0)

* Remove dependency on tailor. Fewer styles checks are performed, but the three
  remaining are the only ones I've found useful.

## 1.2.0 - 31 March 2012 (adce51b9)

* Gracefully handle files with invalid syntax (#1)
* Included class methods in ABC check (#8)
* Can disable style and doc checks from rake task (#9)

## 1.1.0 - 24 March 2012 (ba8a74fc)

* `app` added to default globs
* Added `cane/rake_task`
* `class << obj` syntax ignore by documentation check
* Line length checks no longer include trailing new lines
* Add support for a `.cane` file for setting per-project default options.

## 1.0.0 - 14 January 2012 (4e400534)

* Initial release.
