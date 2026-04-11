require "cmark"

module Marquery
  struct Renderer
    include MarkdownToHtml

    def markdown_to_html(content : String) : String
      options = Cmark::Option.flags(ValidateUTF8, Smart, Unsafe)
      Cmark.gfm_to_html(content.strip, options)
    end
  end
end
