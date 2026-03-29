# Marquery

A compile-time markdown file query engine for Crystal. Parses markdown files
with optional YAML frontmatter at compile time and provides a query interface
with pagination-friendly navigation.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     marquery:
       codeberg: fluck/marquery
   ```

2. Run `shards install`

## Usage

Require the shard in your app:

```crystal
require "marquery"
```

### Setting up a query

Create a query class and include `Marquery::Query`:

```crystal
class Blog::PostQuery
  include Marquery::Query
end
```

This will look for markdown files in `marquery/blog_post/*.md`, derived from the
class name (without the `Query` suffix). For example:

- `Blog::PostQuery` → `marquery/blog_post/*.md`
- `ItemQuery` → `marquery/item/*.md`
- `News::ArticleQuery` → `marquery/news_article/*.md`

To change the default data directory, annotate the `Marquery` module:

```crystal
@[Marquery::Dir("data")]
module Marquery
end
```

Individual query classes can also override the directory:

```crystal
@[Marquery::Dir("db/content")]
class Blog::PostQuery
  include Marquery::Query
end
```

### Markdown files

Entries are markdown files with a date-prefixed filename:

```
marquery/blog_post/20260320_first_post.md
```

The date (`YYYYMMDD`) and name are extracted from the filename. An optional YAML
frontmatter block can override the title and add additional fields:

```markdown
---
title: The very first post
description: >-
  This is the first post.
active: true
tags:
  - crystal
  - web
---

The body of the post goes here.
```

Supported frontmatter types are `Bool`, `Int32`, `Float64`, `String`, `Time`,
and `Array(String)`.

### Custom models

By default, entries are deserialized into `Marquery::Entity`. To use a custom
model, define a struct that includes `Marquery::Model` and declare it in the
query:

```crystal
struct Blog::Post
  include Marquery::Model
end

class Blog::PostQuery
  include Marquery::Query

  model Blog::Post
end
```

`Marquery::Model` includes `JSON::Serializable` and defines the base fields:

| Field         | Type      | Default |
| ------------- | --------- | ------- |
| `slug`        | `String`  |         |
| `title`       | `String`  |         |
| `description` | `String?` | `nil`   |
| `content`     | `String`  |         |
| `date`        | `Time`    |         |
| `active`      | `Bool`    | `true`  |

Additional fields can be added to the custom model and populated through
frontmatter:

```crystal
struct Blog::Post
  include Marquery::Model

  getter tags : Array(String) = [] of String
end
```

The `source` field containing the original file path is also available if you
add it to your model:

```crystal
struct Blog::Post
  include Marquery::Model

  getter source : String
end
```

### Sort order

Entries are sorted by `date` in descending order by default. Use the `order_by`
macro to change the field or direction:

```crystal
class Blog::PostQuery
  include Marquery::Query

  order_by date, Marquery::Order::ASC
end
```

Or sort by a different field:

```crystal
class Blog::PostQuery
  include Marquery::Query

  order_by title
end
```

### HTML rendering

Model instances have a `to_html` method that renders the `content` field to HTML
using [Cmark](https://github.com/amauryt/cr-cmark-gfm) (GitHub Flavored
Markdown) by default:

```crystal
post = Blog::PostQuery.new.find("first-post")
post.to_html # => "<p>The body of the post goes here.</p>\n"
```

### Markdown in pages and components

Include `Marquery::MarkdownHelper` in pages or components of your app to get a
convenient `markdown` method that renders markdown strings to HTML:

```crystal
class Blog::ShowPage
  include Marquery::MarkdownHelper

  def content
    div do
      markdown some_markdown
    end
  end
end
```

### Custom renderer

Both the `to_html` method on models and the `markdown` method in pages use
`Marquery::Renderer` (Cmark GFM) by default. To use a different markdown
renderer, create a struct that includes `Marquery::MarkdownToHtml`:

```crystal
struct MyRenderer
  include Marquery::MarkdownToHtml

  def markdown_to_html(content : String) : String
    MyMarkdownLib.render(content)
  end
end
```

Then declare it on models with `to_html`:

```crystal
struct Blog::Post
  include Marquery::Model

  to_html MyRenderer
end
```

Or on pages and components of your app with `markdown_renderer`:

```crystal
class Blog::ShowPage
  include Marquery::MarkdownHelper

  markdown_renderer MyRenderer
end
```

### Querying

Initialize a query object:

```crystal
query = Blog::PostQuery.new
```

Get all entries:

```crystal
posts = query.all
```

Get the first entry:

```crystal
post = query.first   # raises if not found
post = query.first?  # returns nil if not found
```

Get the last entry:

```crystal
post = query.last   # raises if not found
post = query.last?  # returns nil if not found
```

Find by slug:

```crystal
post = query.find("first-post")   # raises if not found
post = query.find?("first-post")  # returns nil if not found

# => returns a `Marquery::Model` instance of `data/blog_post/20260101_first_post.md`
```

Navigate between entries:

```crystal
prev_post = query.previous(post)  # previous entry in the list, or nil
next_post = query.next(post)      # next entry in the list, or nil
```

Get all entries in randomised order:

```crystal
posts = query.shuffle.all
```

Get all entries in reversed order:

```crystal
posts = query.reverse.all
```

Get all entries sorted:

```crystal
posts = query.sort_by(&.title).all
```

All collection operations can be chained as well:

### Filtering

Use `filter` to narrow down entries. It takes a block and is chainable:

```crystal
Blog::PostQuery.new
  .filter(&.active)
  .filter { |post| post.date >= 1.month.ago }
  .all
```

Since `filter` accepts any block that returns a `Bool`, you can express any
condition without being limited to a predefined set of operators.

### Pagination

The `all` method returns a plain `Array`, so it works with any array-based
pagination solution.

[Lucky](https://luckyframework.org) has built-in array pagination with
`paginate_array`:

```crystal
class Blog::Index < BrowserAction
  get "/blog" do
    pages, posts = paginate_array(Blog::PostQuery.new.all)
    html Blog::IndexPage, posts: posts, pages: pages
  end
end
```

For [Kemal](https://kemalcr.com/) and other frameworks,
[pager](https://github.com/imdrasil/pager) is a good option:

```crystal
require "pager/collections/array"

get "/blog" do |env|
  current_page = env.params.query["page"]?.try(&.to_i) || 0
  posts = Blog::PostQuery.new.all.paginate(current_page, 10)
  # ...
end
```

## Contributing

We use [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/)
for our commit messages, so please adhere to that pattern.

1. Fork it (<https://codeberg.org/fluck/marquery/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'feat: new feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Wout](https://codeberg.org/w0u7) - creator and maintainer
