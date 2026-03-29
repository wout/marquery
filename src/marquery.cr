require "json"
require "./marquery/version"
require "./marquery/order"
require "./marquery/markdown_to_html"
require "./marquery/renderer"
require "./marquery/markdown_helper"
require "./marquery/model"
require "./marquery/entry"
require "./marquery/query"

module Marquery
  annotation Dir; end

  macro load_entries(path)
    {%
      entries = run("./run_macros/parser", path)
      unless entries.starts_with?('[')
        raise "Failed to parse entries: #{entries.stringify}"
      end
    %}
    {{ entries.stringify }}
  end
end
