require "../spec_helper"

describe Marquery::Model do
  it "defines base fields on the including type" do
    post = TestPostQuery.new.all.first

    post.slug.should be_a(String)
    post.title.should be_a(String)
    post.content.should be_a(String)
    post.date.should be_a(Time)
    post.active?.should be_a(Bool)
  end

  it "makes description optional" do
    post = TestPostQuery.new.find("third-post")

    post.description.should be_nil
  end

  it "defaults active to true" do
    post = TestPostQuery.new.find("second-post")

    post.active?.should eq(true)
  end

  it "reads active from frontmatter" do
    post = TestPostQuery.new.find("first-post")

    post.active?.should eq(false)
  end

  describe "#to_html" do
    it "renders content as html" do
      post = TestPostQuery.new.find("third-post")

      post.to_html.should contain("<p>Just a post without frontmatter.</p>")
    end

    it "renders multiple paragraphs" do
      post = TestPostQuery.new.find("first-post")
      html = post.to_html

      html.should contain("<p>This is the body of the first post.</p>")
      html.should contain("<p>It has multiple paragraphs.</p>")
    end

    it "accepts a custom renderer" do
      post = CustomRendererPost.from_json({
        slug:    "test",
        title:   "Test",
        content: "Hello",
        date:    "2026-01-01T00:00:00Z",
      }.to_json)

      post.to_html.should eq("<custom>Hello</custom>")
    end

    it "passes content through process_content before rendering" do
      post = PreProcessedPost.from_json({
        slug:    "test",
        title:   "Hello world",
        content: "# {{title}}",
        date:    "2026-01-01T00:00:00Z",
      }.to_json)

      post.to_html.should contain("<h1>Hello world</h1>")
    end

    it "rewrites asset: URIs to resolved asset paths" do
      post = TestPost.from_json({
        slug:    "test",
        title:   "Test",
        content: "![Hero](asset:hero.png)",
        date:    "2026-01-01T00:00:00Z",
        source:  "n/a",
        assets:  {"hero.png" => "marquery/test/hero.png"},
      }.to_json)

      post.to_html.should contain(%(src="/marquery/test/hero.png"))
    end

    it "raises AssetNotFound for unknown asset: URIs" do
      post = TestPost.from_json({
        slug:    "test",
        title:   "Test",
        content: "![Missing](asset:nope.png)",
        date:    "2026-01-01T00:00:00Z",
        source:  "n/a",
      }.to_json)

      expect_raises(Marquery::AssetNotFound) { post.to_html }
    end
  end
end
