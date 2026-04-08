require "../spec_helper"

describe Marquery::MarkdownHelper do
  it "renders markdown with the default renderer" do
    page = DefaultHelperPage.new

    page.render("Hello **world**").should contain("<strong>world</strong>")
  end

  it "accepts a model instance" do
    page = DefaultHelperPage.new
    post = TestPostQuery.new.first

    page.render(post).should contain("<p>")
  end

  it "accepts a collection instance" do
    page = DefaultHelperPage.new
    index = TestPostQuery.index

    page.render(index).should contain("<p>")
  end

  it "accepts a custom renderer" do
    page = CustomHelperPage.new

    page.render("Hello").should eq("<custom>Hello</custom>")
  end
end
