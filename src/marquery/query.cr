module Marquery
  module Query
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

        delegate first, first?, last, last?, to: @entries

        def initialize
          @entries = @@entries.dup
        end

        def all : Array(MarqueryModel)
          @entries
        end

        def reverse : self
          @entries.reverse!
          self
        end

        def shuffle(random : Random? = nil) : self
          @entries.shuffle!(random)
          self
        end

        def sort_by(&block : MarqueryModel -> _) : self
          @entries.sort_by!(&block)
          self
        end

        def filter(&block : MarqueryModel -> Bool) : self
          @entries.select!(&block)
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
end
