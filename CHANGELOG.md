# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] - 2026-04-08

### Added

- Asset support: images and media files alongside markdown entries in matching
  directories (e.g. `20260320_first_post/hero.png`)
- `Marquery::Renderable` mixin extracted from `Model` for shared content,
  assets, and rendering logic
- `assets` getter and `asset(name)`/`asset?(name)` methods on entries and
  index pages returning URL-ready paths
- `Marquery::AssetHandler` HTTP handler for serving entry assets from
  configured data directories
- `Marquery::Collection` mixin for index metadata (title, description,
  content, assets, `to_html`)
- `Marquery::Index` default struct for collection index pages
- `index` macro on query classes for custom index models
- `.index` class method on query classes returning the parsed `_index.md`
- `.dir` class method on query classes returning the data directory path
- `Marquery::AssetNotFound` exception class raised by `asset`

## [0.3.0] - 2026-04-07

### Added

- `Marquery::Error` base exception class for all library errors
- `Marquery::EntryNotFound` exception class raised by `find` for rescuable
  error handling

### Fixed

- Replaced deprecated `Random::DEFAULT` with `Random.new` in `shuffle`

## [0.2.0] - 2026-03-29

### Added

- HTML rendering via `to_html` on model instances, using Cmark (GFM) by default
- `Marquery::MarkdownToHtml` module defining the renderer interface
- `Marquery::Renderer` struct as the default Cmark-based renderer
- `Marquery::MarkdownHelper` module for convenient `markdown` method in pages and
  components, with automatic `raw` wrapping in Lucky and a `Model` overload
- `to_html` macro on `Marquery::Model` to declare a custom renderer
- `markdown_renderer` macro on `Marquery::MarkdownHelper` to declare a custom
  renderer
- `Marquery::Query` module extracted from `Marquery` for clearer usage
- Chainable `reverse`, `shuffle`, and `sort_by` methods on query objects
- Delegated `first`, `first?`, `last`, and `last?` methods on query objects
- `Array(String)` support in frontmatter (e.g. for tags)
- `source` field in parser output for access to the original file path
- `Marquery::Dir` annotation to configure the data directory globally or per query
- `cmark` (cr-cmark-gfm) as a dependency

### Changed

- Default data directory changed from `data` to `marquery`
- Query logic moved from `Marquery` to `Marquery::Query` module
- Renamed `Marquery::Entity` to `Marquery::Entry`

## [0.1.0] - 2026-03-20

### Added

- Compile-time markdown file parsing with optional YAML frontmatter
- `Marquery::Model` mixin with base fields (slug, title, description, content, date, active)
- `Marquery::Entry` as default model
- Query interface with `all`, `find`, `find?`, `filter`, `previous`, `next`
- Configurable sort order via `order_by` macro
- Custom model support via `model` macro
