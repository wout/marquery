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
