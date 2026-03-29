module Marquery
  module MarkdownToHtml
    abstract def markdown_to_html(content : String) : String
  end
end
