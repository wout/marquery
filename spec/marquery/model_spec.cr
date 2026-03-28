require "../spec_helper"

describe Marquery::Model do
  it "defines base fields on the including type" do
    post = TestPostQuery.new.all.first

    post.slug.should be_a(String)
    post.title.should be_a(String)
    post.content.should be_a(String)
    post.date.should be_a(Time)
    post.active.should be_a(Bool)
  end

  it "makes description optional" do
    post = TestPostQuery.new.find("third-post")

    post.description.should be_nil
  end

  it "defaults active to true" do
    post = TestPostQuery.new.find("second-post")

    post.active.should eq(true)
  end

  it "reads active from frontmatter" do
    post = TestPostQuery.new.find("first-post")

    post.active.should eq(false)
  end
end
