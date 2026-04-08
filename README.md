# Marquery

[![CI](https://codeberg.org/fluck/marquery/actions/workflows/ci.yml/badge.svg)](https://codeberg.org/fluck/marquery/actions?workflow=ci.yml)
[![Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fcodeberg.org%2Fapi%2Fv1%2Frepos%2Ffluck%2Fmarquery%2Ftags&query=%24%5B0%5D.name&label=version)](https://codeberg.org/fluck/marquery/tags)

A compile-time markdown file query engine for Crystal. Drop your markdown files
in a directory, define a query class, and get a type-safe, filterable,
pagination-ready collection baked right into your binary. No database, no
runtime parsing.

- **Low runtime overhead.** Markdown is parsed at compile time and embedded in
  the binary.
- **Frontmatter support.** YAML frontmatter for metadata like title,
  description, tags, and custom fields.
- **Chainable queries.** Filter, sort, reverse, shuffle, navigate, and more.
- **Built-in HTML rendering.** Cmark GFM out of the box, or bring your own
  renderer.
- **Framework-friendly.** Works with Lucky, Kemal, or any Crystal app.

> [!Note]
> The original repository is hosted at
> [Codeberg](https://codeberg.org/fluck/marquery). The [GitHub
> repo](https://github.com/flucksite/marquery) is just a mirror.

## Quick start

```crystal
require "marquery"

class Blog::PostQuery
  include Marquery::Query
end

query = Blog::PostQuery.new
query.filter(&.active?).sort_by(&.title).all
query.find("my-first-post").to_html
```

Add your markdown files to `marquery/blog_post/` and you're good to go:

```
marquery/blog_post/20260320_my_first_post.md
marquery/blog_post/20260323_another_post.md
```

That's it.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     marquery:
       codeberg: fluck/marquery
   ```

2. Run `shards install`

## Markdown files

Entries are markdown files with a date-prefixed filename:

```
marquery/blog_post/20260320_first_post.md
```

The date (`YYYYMMDD`) and name are extracted from the filename. The name becomes
the slug (hyphenated) and title (humanized). An optional YAML frontmatter block
can override these and add custom fields:

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

> [!NOTE]
> Supported frontmatter types: `Bool`, `Int32`, `Float64`, `String`, `Time`,
> and `Array(String)`.

## Models

By default, entries are deserialized into `Marquery::Entry`. For custom fields,
define a struct that includes `Marquery::Model`:

```crystal
struct Blog::Post
  include Marquery::Model

  getter tags : Array(String) = [] of String
end
```

The base fields provided by `Marquery::Model` are:

- `slug` (`String`)
- `title` (`String`)
- `description` (`String?`)
- `content` (`String`)
- `date` (`Time`)
- `active?` (`Bool`, defaults to `true`).

The original markdown file path is also available if you add it to your model:

```crystal
struct Blog::Post
  include Marquery::Model

  getter source : String
end
```

## Queries

Create a query class and include `Marquery::Query`:

```crystal
class Blog::PostQuery
  include Marquery::Query

  model Blog::Post
end
```

The data directory is derived from the class name (without the `Query` suffix):

- `Blog::PostQuery` -> `marquery/blog_post/*.md`
- `ItemQuery` -> `marquery/item/*.md`
- `News::ArticleQuery` -> `marquery/news_article/*.md`

### Querying

```crystal
query = Blog::PostQuery.new

query.all                     # all entries
query.first                   # first entry (raises if empty)
query.first?                  # first entry or nil
query.last                    # last entry (raises if empty)
query.last?                   # last entry or nil
query.find("first-post")      # find by slug (raises if not found)
query.find?("first-post")     # find by slug or nil
query.previous(post)          # previous entry or nil
query.next(post)              # next entry or nil
```

### Error handling

Query methods raise typed exceptions that you can rescue from:

```crystal
begin
  Blog::PostQuery.new.find("nonexistent")
rescue ex : Marquery::EntryNotFound
  puts ex.message # => "Entry not found: nonexistent"
end
```

All library exceptions inherit from `Marquery::Error`, so you can also catch
them all:

```crystal
rescue ex : Marquery::Error
  # ...
end
```

### Filtering, sorting, and chaining

`filter`, `sort_by`, `reverse`, and `shuffle` all return `self`, so they chain
naturally:

```crystal
Blog::PostQuery.new
  .filter(&.active?)
  .filter { |post| post.date >= 1.month.ago }
  .filter(&.tags.includes?("crystal"))
  .sort_by(&.title)
  .all
```

> [!NOTE]
> Since `filter` is just a thin wrapper around `Array#select`, you can express
> any condition.

### Default sort order

Entries are sorted by `date` descending by default. Use `order_by` to change
the default:

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

## Index pages

Each query can have an index page with metadata for the collection itself
(e.g. page title, meta description). Create a `_index.md` file in the data
directory:

```
marquery/blog_post/_index.md
marquery/blog_post/_index/og-image.png
```

```markdown
---
title: Blog
description: Thoughts on Crystal and web development.
---

Welcome to the blog.
```

Access it via the query class:

```crystal
Blog::PostQuery.index.title       # => "Blog"
Blog::PostQuery.index.description # => "Thoughts on Crystal and web development."
Blog::PostQuery.index.to_html     # => "<p>Welcome to the blog.</p>\n"
```

If no `_index.md` exists, the index returns empty defaults.

### Custom index model

For custom fields, create a struct that includes `Marquery::Collection` and
assign it with the `index` macro:

```crystal
struct Blog::PostIndex
  include Marquery::Collection

  getter subtitle : String?
end

class Blog::PostQuery
  include Marquery::Query

  index Blog::PostIndex
end
```

## HTML rendering

Model instances have a `to_html` method that renders the `content` field to HTML
using [Cmark](https://github.com/amauryt/cr-cmark-gfm) (GitHub Flavored
Markdown) by default:

```crystal
post = Blog::PostQuery.new.find("first-post")
post.to_html # => "<p>The body of the post goes here.</p>\n"
```

### Custom renderer

To use a different markdown renderer, create a struct that includes
`Marquery::MarkdownToHtml`:

```crystal
struct MyRenderer
  include Marquery::MarkdownToHtml

  def markdown_to_html(content : String) : String
    MyMarkdownLib.render(content)
  end
end
```

Then declare it on your model with `to_html`:

```crystal
struct Blog::Post
  include Marquery::Model

  to_html MyRenderer
end
```

### Markdown in pages and components

Include `Marquery::MarkdownHelper` in pages or components of your app to get a
convenient `markdown` method:

```crystal
class Blog::ShowPage
  include Marquery::MarkdownHelper

  def content
    div do
      # Accepts a String
      markdown "**Something**"

      # Or an instance of Marquery::Model
      markdown post
    end
  end
end
```

> [!NOTE]
> In Lucky apps, the output is automatically wrapped in `raw`.

To use a custom renderer in pages, use the `markdown_renderer` macro:

```crystal
class Blog::ShowPage
  include Marquery::MarkdownHelper

  markdown_renderer MyRenderer
end
```

## Assets

Place images and media files in a directory matching the markdown filename
(without the `.md` extension):

```
marquery/blog_post/20260320_first_post.md
marquery/blog_post/20260320_first_post/hero.png
marquery/blog_post/20260320_first_post/diagram.svg
```

The assets are available on the entry at compile time:

```crystal
post = Blog::PostQuery.new.find("first-post")
post.asset("hero.png")  # => "/marquery/blog_post/20260320_first_post/hero.png"
post.asset?("missing")  # => nil
post.assets             # => {"hero.png" => "marquery/blog_post/...", ...}
```

> [!NOTE]
> Supported file types: `.avif`, `.gif`, `.jpeg`, `.jpg`, `.mp3`, `.mp4`,
> `.ogg`, `.pdf`, `.png`, `.svg`, `.webm`, `.webp`. Dotfiles are ignored.

### Serving assets

To serve asset files over HTTP, add `Marquery::AssetHandler` to your middleware:

```crystal
require "marquery/asset_handler"

# Lucky
class AppServer < Lucky::BaseAppServer
  def middleware : Array(HTTP::Handler)
    [
      # ... other handlers ...
      Marquery::AssetHandler.new(Blog::PostQuery.dir, News::ArticleQuery.dir),
      # ...
    ] of HTTP::Handler
  end
end

# Kemal
add_handler Marquery::AssetHandler.new(Blog::PostQuery.dir)
```

The handler serves files from the configured directories and falls through
for anything else.

## Configuring the data directory

The default data directory is `marquery/`. To change it globally, annotate the
`Marquery` module:

```crystal
# e.g. config/marquery.cr

@[Marquery::Dir("data")]
module Marquery
end
```

Individual query classes can override the directory:

```crystal
@[Marquery::Dir("db/content")]
class Blog::PostQuery
  include Marquery::Query
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
