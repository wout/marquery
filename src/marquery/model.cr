module Marquery
  module Model
    macro included
      include JSON::Serializable

      getter slug : String
      getter title : String
      getter description : String?
      getter content : String
      getter date : Time
      getter? active : Bool = true
      getter assets : Hash(String, String) = {} of String => String

      def asset(name : String) : String
        "/#{assets[name]? || raise ::Marquery::AssetNotFound.new(name)}"
      end

      def asset?(name : String) : String?
        assets[name]?.try(&.prepend("/"))
      end

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
