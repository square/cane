require 'xspec_helper'

require 'cane/json_formatter'

describe Cane::JsonFormatter do
  it 'outputs violations as JSON' do
    violations = [{description: 'Fail', line: 3}]
    assert_equal [{'description' => 'Fail', 'line' => 3}],
      JSON.parse(Cane::JsonFormatter.new(violations).to_s)
  end
end
