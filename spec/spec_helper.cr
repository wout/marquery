require "spec"
require "../src/marquery"

struct TestPost
  include Marquery::Model

  getter source : String
  getter tags : Array(String) = [] of String
end

class TestPostQuery
  include Marquery::Query

  model TestPost
end

class TestPostAscQuery
  include Marquery::Query

  model TestPost
  order_by date, Marquery::Order::ASC
end

class TestPostByTitleQuery
  include Marquery::Query

  model TestPost
  order_by title
end

struct TestPostIndex
  include Marquery::Collection

  getter subtitle : String?
end

class TestPostCustomIndexQuery
  include Marquery::Query

  model TestPost
  index TestPostIndex
end

class DefaultModelQuery
  include Marquery::Query
end

@[Marquery::Assets("marquery/test_post_assets")]
class TestPostSharedAssetQuery
  include Marquery::Query

  model TestPost
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

struct PreProcessedPost
  include Marquery::Model

  def process_content(raw : String) : String
    raw.gsub("{{title}}", title)
  end
end

class DefaultHelperPage
  include Marquery::MarkdownHelper

  def render(content : String) : String
    markdown(content)
  end

  def render(renderable : Marquery::Renderable)
    markdown(renderable)
  end
end

class CustomHelperPage
  include Marquery::MarkdownHelper

  markdown_renderer CustomRenderer

  def render(content : String) : String
    markdown(content)
  end
end
