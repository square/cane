# Cane History

## 2.2.1 - 26 August 2012 (b5e5a362)

* Bugfix: parallel option can be set in rake tasks

## 2.2.0 - 26 August 2012 (f4198619)

* Gracefully handle ambiguous options like `-abc-max` (#27)
* Provide the `--parallel` option to use all processors. This will be faster on
  larger projects, but slower on smaller ones (#28)

## 2.1.0 - 26 August 2012 (2962d8fb)

* Support for user-defined checks (#30)

## 2.0.0 - 19 August 2012 (35cae086)

* ABC check labels  `MyClass = Struct.new {}` and `Class.new` correctly (#20)
* Magic comments (`# encoding: utf-8`) are not recognized as appropriate class documentation (#21)
* Invalid UTF-8 is handled correctly (#22)
* Gracefully handle unknown options
* ABC check output uses a standard format (`Foo::Bar#method` rather than `Foo > Bar > method`)
* **BREAKING** Add `--abc-exclude`, `--style-exclude` CLI flags, remove YAML support
* **BREAKING-INTERNAL** Use hashes rather than explicit violation classes
* **BREAKING-INTERNAL** Remove translator class, pass CLI args direct to checks
* **INTERNAL** Wiring in a new check only requires changing one file (#15)

This snippet will convert your YAML exclusions file to the new CLI syntax:

    y = YAML.load(File.read('exclusions.yml'))
    puts (
      y.fetch('abc',   []).map {|x| %|--abc-exclude "#{x}"| } +
      y.fetch('style', []).map {|x| %|--style-exclude "#{x}"| }
    ).join("\n")

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
