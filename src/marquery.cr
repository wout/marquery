require "json"
require "./marquery/version"
require "./marquery/order"
require "./marquery/markdown_to_html"
require "./marquery/renderer"
require "./marquery/markdown_helper"
require "./marquery/model"
require "./marquery/entity"

module Marquery
  macro load_entries(path)
    {%
      entries = run("./run_macros/parser", path)
      unless entries.starts_with?('[')
        raise "Failed to parse entries: #{entries.stringify}"
      end
    %}
    {{ entries.stringify }}
  end

  macro included
    macro model(klass)
      alias MarqueryModel = \{{klass}}
    end

    macro order_by(field, order = ::Marquery::Order::DESC)
      MARQUERY_ORDER = { \{{field.id.symbolize}}, \{{order}} }

      private def self.sort_entries(
        entries : Array(MarqueryModel)
      ) : Array(MarqueryModel)
        sorted = entries.sort_by(&.\{{field.id}})
        sorted.reverse! if \{{order}}.desc?
        sorted
      end
    end

    macro finished
      \{% unless @type.has_constant?("MarqueryModel") %}
        alias MarqueryModel = ::Marquery::Entity
      \{% end %}

      \{% unless @type.has_constant?("MARQUERY_ORDER") %}
        order_by date
      \{% end %}

      \{% path = @type.name.gsub(/Query/, "").gsub(/::/, "").underscore %}

      @entries : Array(MarqueryModel)
      @@entries : Array(MarqueryModel) = sort_entries(
        Array(MarqueryModel).from_json(::Marquery.load_entries(\{{ path }}))
      )

      def initialize
        @entries = @@entries
      end

      def all : Array(MarqueryModel)
        @entries
      end

      def filter(&block : MarqueryModel -> Bool) : self
        @entries = @entries.select(&block)
        self
      end

      def find(slug : String) : MarqueryModel
        find?(slug) || raise "Entry not found: #{slug}"
      end

      def find?(slug : String) : MarqueryModel?
        @entries.find(&.slug.==(slug))
      end

      def previous(entry : MarqueryModel) : MarqueryModel?
        return unless index = @entries.index(entry)

        @entries[index - 1]? unless index == 0
      end

      def next(entry : MarqueryModel) : MarqueryModel?
        return unless index = @entries.index(entry)

        @entries[index + 1]?
      end
    end
  end
end
