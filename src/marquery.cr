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
require "./marquery/asset_handler"

module Marquery
  annotation Dir; end
  annotation Assets; end

  macro load_index(path, assets_path = nil)
    {%
      lines = if assets_path
                run("./run_macros/parser", path, assets_path).split("\n")
              else
                run("./run_macros/parser", path).split("\n")
              end
      index = lines[0].id
      unless index.starts_with?('{')
        raise "Failed to parse index: #{index.stringify}"
      end
    %}
    {{ index.stringify }}
  end

  macro load_entries(path, assets_path = nil)
    {%
      lines = if assets_path
                run("./run_macros/parser", path, assets_path).split("\n")
              else
                run("./run_macros/parser", path).split("\n")
              end
      entries = lines[1].id
      unless entries.starts_with?('[')
        raise "Failed to parse entries: #{entries.stringify}"
      end
    %}
    {{ entries.stringify }}
  end
end
