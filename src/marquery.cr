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

  struct Data(Index, Entry)
    include JSON::Serializable

    getter index : Index
    getter entries : Array(Entry)
  end

  macro load(path, assets_path = nil)
    {%
      source = run("./run_macros/parser", path, assets_path || "").chomp.id
      unless source.starts_with?('{')
        raise "Failed to parse parser output: #{source.stringify}"
      end
    %}

    @@marquery_data = ::Marquery::Data(MarqueryIndex, MarqueryModel)
      .from_json({{ source.stringify }})
    @@entries : Array(MarqueryModel) = sort_entries(@@marquery_data.entries)

    def self.index : MarqueryIndex
      @@marquery_data.index
    end
  end
end
