# Cane History

## 2.6.2 - 20 April 2014 (8f54b4)

* Bugfix: Commented methods no longer trigger a documentation violation for
  empty modules.
* Feature: Ruby 2.1 supported.

## 2.6.1 - 30 October 2013 (2ea008)

* Feature: Don't require doc for one-line class w/out method.
* Bugfix: JsonFormatter initializer needs to take an options hash.
* Doc: Add license definition to gemspec.

## 2.6.0 - 7 June 2013 (616bb8a5)

* Feature: classes with no methods do not require documentation.
* Feature: modules with methods require documentation.
* Feature: support all README extensions.
* Feature: --color option.
* Bugfix: fix false positive on class matching for doc check.
* Bugfix: better handling of invalid strings.
* Compat: fix Ruby 2.0 deprecations.

## 2.5.2 - 26 January 2013 (a0cf38ba)

* Feature: support operators beside `>=` in threshold check.

## 2.5.1 - 26 January 2013 (93819f19)

* Feature: documentation check supports `.mdown` and `.rdoc` extensions.
* Feature: expanded threshold regex to support `coverage/.last_run.json` from
  `SimpleCov`.
* Compat: Ruby 2.0 compatibility.

## 2.5.0 - 17 November 2012 (628cc1e9)

* Feature: `--doc-exclude` option to exclude globs from documentation checks.
* Feature: `--style-exclude` supports globbing.

## 2.4.0 - 21 October 2012 (46949e77)

* Feature: Rake task can load configuration from a `.cane` file.
* Feature: Coverage threshold can be specifed in a file.
* Feature: Provide `--all` option for working with single files.
* Bugfix: Allow README file to be lowercase.

## 2.3.0 - 16 September 2012 (229252ff)

* Feature: `--json` option for machine-readable output.
* Feature: absence of a README will cause a failure.
* Bugfix: `--no-style` option actually works now.

## 2.2.3 - 3 September 2012 (e4fe90ee)

* Bugfix: Allow multiple spaces before class name. (#34)
* Bugfix: Remove wacky broken conditional in AbcCheck. (#33)
* Doc: Better guidance on class level comments. (#35)

## 2.2.2 - 29 August 2012 (3a9be454)

* Bugfix: Stricter magic comment regex to avoid false positives (#31)

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
