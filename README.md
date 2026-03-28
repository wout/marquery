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

Create a query class and include `Marquery`:

```crystal
class Blog::PostQuery
  include Marquery
end
```

This will look for markdown files in `data/blog_post/*.md`, derived from the
class name (without the `Query` suffix). For example:

- `Blog::PostQuery` → `data/blog_post/*.md`
- `ItemQuery` → `data/item/*.md`
- `News::ArticleQuery` → `data/news_article/*.md`

### Markdown files

Entries are markdown files with a date-prefixed filename:

```
data/blog_post/20260320_first_post.md
```

The date (`YYYYMMDD`) and name are extracted from the filename. An optional YAML
frontmatter block can override the title and add additional fields:

```markdown
---
title: The very first post
description: >-
  This is the first post.
active: true
---

The body of the post goes here.
```

### Custom models

By default, entries are deserialized into `Marquery::Entity`. To use a custom
model, define a struct that includes `Marquery::Model` and declare it in the
query:

```crystal
struct Blog::Post
  include Marquery::Model
end

class Blog::PostQuery
  include Marquery

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
| `active`      | `Bool`    | `false` |

Additional fields can be added to the custom model and populated through
frontmatter.

### Sort order

Entries are sorted by `date` in descending order by default. Use `order_by` to
change the field or direction:

```crystal
class Blog::PostQuery
  include Marquery

  order_by date, Marquery::Order::ASC
end
```

Or sort by a different field:

```crystal
class Blog::PostQuery
  include Marquery

  order_by title
end
```

### Querying

```crystal
query = Blog::PostQuery.new

# Get all entries
query.all

# Find by slug
query.find("first_post")   # raises if not found
query.find?("first_post")  # returns nil if not found

# Navigate between entries
query.previous(post)  # previous entry in the list, or nil
query.next(post)      # next entry in the list, or nil
```

### Pagination

The `all` method returns a plain `Array`, so it works with any array-based
pagination solution.

#### Lucky

Lucky has built-in array pagination with `paginate_array`:

```crystal
class Blog::Index < BrowserAction
  get "/blog" do
    pages, posts = paginate_array(Blog::PostQuery.new.all)
    html Blog::IndexPage, posts: posts, pages: pages
  end
end
```

#### Other frameworks

For Kemal and other frameworks,
[pager](https://github.com/imdrasil/pager) is a good option:

```crystal
require "pager/collections/array"

get "/blog" do |env|
  curent_page = env.params.query["page"]?.try(&.to_i) || 0
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
