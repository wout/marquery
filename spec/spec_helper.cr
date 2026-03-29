require "spec"
require "../src/marquery"

struct TestPost
  include Marquery::Model
end

class TestPostQuery
  include Marquery

  model TestPost
end

class TestPostAscQuery
  include Marquery

  model TestPost
  order_by date, Marquery::Order::ASC
end

class TestPostByTitleQuery
  include Marquery

  model TestPost
  order_by title
end

class DefaultModelQuery
  include Marquery
end

struct CustomRenderer
  include Marquery::MarkdownToHtml

  def markdown_to_html(content : String) : String
    "<custom>#{content}</custom>"
  end
end

struct CustomRendererPost
  include Marquery::Model

  to_html CustomRenderer
end
