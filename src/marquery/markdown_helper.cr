module Marquery
  module MarkdownHelper
    macro included
      macro markdown_renderer(klass)
        RENDERER = \{{klass}}

        private def markdown(content : String) : String
          \{{klass}}.new.markdown_to_html(content)
        end
      end

      macro finished
        \{% unless @type.has_constant?("RENDERER") %}
          markdown_renderer ::Marquery::Renderer
        \{% end %}
      end
    end
  end
end
