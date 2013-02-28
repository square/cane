module Cane
  # Computes a string of HTML displayed from an array of violations
  # computed by the checks.
  class HtmlFormatter
    attr_reader :violations

    def initialize violations, opts={}
      @violations = violations
    end

    def to_s
      html
    end

    protected
    def description_groups
      violations.group_by {|v| v[:description]}
    end

    def violations_content
      description_groups.each_with_object('') do |grp, _html|
        _html << tableize(*grp)
      end
    end

    def rows_for_violations vs
      keys = vs.first.keys - [:description].sort
      html_str = "<tr>\n"
      keys.map {|k| html_str << "<th>#{k.upcase}</th>\n"}
      html_str << "</tr>\n"
      vs.each do |violation|
        html_str << "<tr>\n"
        keys.map {|k| html_str << "<td>#{violation[k]}</td>\n"}
        html_str << "</tr>\n"
      end
      html_str
    end

    def totals
      "Total Violations: #{violations.length}"
    end

    def html
      <<-HTML
        <!doctype html>
        <html lang=en>
        <head>
        <meta charset=utf-8>
        <title>Cane Results</title>
        <style type="text/css">
              body {
                color: #333;
                background: #eee;
                padding: 0 20px;
              }
              p {
                margin: 5px 0;
              }
              table {
                background: white;
                border: 1px solid #666;
                border-collapse: collapse;
                margin: 10px 0;
                font-size: 14px;
              }
              table caption {
                font-size: 18px;
              }
              table th, table td {
                padding: 4px;
                border: 1px solid #D0D1D1;
              }
              table th {
                background-color: #DFC111;
                color: #337039;
              }
              table td {
                color: #592914;
              }
            </style>
        </head>
        <body>
        <h1>Cane Results</h1>
        <p>#{totals}</p>
        #{violations_content}
        </body>
        </html>
      HTML
    end

    def tableize description, violations_for_description
      <<-TABLE
        <table>
        <caption>#{description}</caption>
        #{rows_for_violations(violations_for_description)}
        </table>
      TABLE
    end
  end
end

