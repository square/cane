require 'xspec_helper'

require 'cane/violation_formatter'

describe Cane::ViolationFormatter do
  def violation(description)
    {
      description: description
    }
  end

  it 'includes number of violations in the group header' do
    assert_include "(1)",
      Cane::ViolationFormatter.new([violation("")]).to_s
  end

  it 'includes total number of violations' do
    violations = [violation(""), violation("")]
    result = Cane::ViolationFormatter.new(violations).to_s
    assert_include "Total Violations: 2", result
  end

  it 'does not colorize output by default' do
    result = Cane::ViolationFormatter.new([violation("")]).to_s
    assert !result.include?("\e[31m")
  end

  it 'colorizes output when passed color: true' do
    result = Cane::ViolationFormatter.new([violation("")], color: true).to_s
    assert_include "\e[31m", result
    assert_include "\e[0m", result
  end

  it 'does not colorize output if max_violations is not crossed' do
    options = { color: true, max_violations: 1 }
    result = Cane::ViolationFormatter.new([violation("")], options).to_s

    assert !result.include?("\e[31m")
  end
end
