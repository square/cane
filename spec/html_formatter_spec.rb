require 'spec_helper'

require 'cane/html_formatter'

describe Cane::HtmlFormatter do
  it 'outputs violations as HTML' do
    violations = [{description: 'Fail', line: 3}, {description: 'No', value: 2}]
    result = described_class.new(violations).to_s
    result.should include("<caption>Fail</caption>")
    result.should include("<caption>No</caption>")
    result.should include("<th>VALUE</th>")
    result.should include("<th>LINE</th>")
    result.should include("Total Violations: 2")
  end

  it 'reports no violations correctly' do
    result = described_class.new([]).to_s
    result.should include("Total Violations: 0")
  end
end
