require 'spec_helper'

require 'cane/json_formatter'

describe Cane::JsonFormatter do
  it 'outputs violations as JSON' do
    violations = [{description: 'Fail', line: 3}]
    expect(JSON.parse(described_class.new(violations).to_s)).to eq(
      [{'description' => 'Fail', 'line' => 3}]
    )
  end
end
