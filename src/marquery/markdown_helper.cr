module Marquery
  module MarkdownHelper
    macro included
      macro markdown_renderer(klass)
        MARQUERY_RENDERER = \{{klass}}
      end

      macro finished
        \{% unless @type.has_constant?("MARQUERY_RENDERER") %}
          markdown_renderer ::Marquery::Renderer
        \{% end %}

        \{% if @type.has_method?("raw") && @top_level.has_constant?("Lucky") %}
          private def markdown(content : String)
            raw MARQUERY_RENDERER.new.markdown_to_html(content)
          end
        \{% else %}
          private def markdown(content : String) : String
            MARQUERY_RENDERER.new.markdown_to_html(content)
          end
        \{% end %}
      end
    end
  end
end
