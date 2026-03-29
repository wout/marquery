module Marquery
  module Model
    macro included
      include JSON::Serializable

      getter slug : String
      getter title : String
      getter description : String?
      getter content : String
      getter date : Time
      getter active : Bool = true

      macro to_html(renderer = ::Marquery::Renderer)
        MARQUERY_RENDERER = \{{renderer}}

        def to_html : String
          \{{renderer}}.new.markdown_to_html(content)
        end
      end

      macro finished
        \{% unless @type.has_constant?("MARQUERY_RENDERER") %}
          to_html
        \{% end %}
      end
    end
  end
end
