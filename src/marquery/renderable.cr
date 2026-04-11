module Marquery
  module Renderable
    macro included
      getter assets : Hash(String, String) = {} of String => String

      def asset(name : String) : String
        "/#{assets[name]? || raise ::Marquery::AssetNotFound.new(name)}"
      end

      def asset?(name : String) : String?
        assets[name]?.try { |path| "/#{path}" }
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
