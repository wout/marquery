# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-03-29

### Added

- HTML rendering via `to_html` on model instances, using Cmark (GFM) by default
- `Marquery::MarkdownToHtml` module defining the renderer interface
- `Marquery::Renderer` struct as the default Cmark-based renderer
- `Marquery::MarkdownHelper` module for convenient `markdown` method in pages and components
- `to_html` macro on `Marquery::Model` to declare a custom renderer
- `markdown_renderer` macro on `Marquery::MarkdownHelper` to declare a custom renderer
- `cmark` (cr-cmark-gfm) as a dependency

## [0.1.0] - 2026-03-20

### Added

- Compile-time markdown file parsing with optional YAML frontmatter
- `Marquery::Model` mixin with base fields (slug, title, description, content, date, active)
- `Marquery::Entity` as default model
- Query interface with `all`, `find`, `find?`, `filter`, `previous`, `next`
- Configurable sort order via `order_by` macro
- Custom model support via `model` macro
