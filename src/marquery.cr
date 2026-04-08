require "json"
require "./marquery/error"
require "./marquery/version"
require "./marquery/order"
require "./marquery/markdown_to_html"
require "./marquery/renderer"
require "./marquery/markdown_helper"
require "./marquery/renderable"
require "./marquery/model"
require "./marquery/entry"
require "./marquery/collection"
require "./marquery/index"
require "./marquery/query"

module Marquery
  annotation Dir; end

  macro load(path)
    {%
      data = run("./run_macros/parser", path)
      unless data.starts_with?('{')
        raise "Failed to parse data: #{data.stringify}"
      end
    %}
    {{ data.stringify }}
  end
end
