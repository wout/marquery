require "../spec_helper"

describe "Query" do
  describe "#all" do
    it "returns all entries" do
      TestPostQuery.new.all.size.should eq(3)
    end

    it "sorts by date descending by default" do
      posts = TestPostQuery.new.all

      posts.first.slug.should eq("third-post")
      posts.last.slug.should eq("first-post")
    end
  end

  describe "#find" do
    it "finds an entry by slug" do
      post = TestPostQuery.new.find("first-post")

      post.title.should eq("The very first post")
    end

    it "raises when the entry is not found" do
      expect_raises(Exception, "Entry not found: nonexistent") do
        TestPostQuery.new.find("nonexistent")
      end
    end
  end

  describe "#find?" do
    it "finds an entry by slug" do
      post = TestPostQuery.new.find?("second-post")

      post.should_not be_nil
      post.as(TestPost).title.should eq("Second post")
    end

    it "returns nil when the entry is not found" do
      TestPostQuery.new.find?("nonexistent").should be_nil
    end
  end

  describe "#previous" do
    it "returns the previous entry in the list" do
      query = TestPostQuery.new
      second = query.find("second-post")
      previous = query.previous(second)

      previous.should_not be_nil
      previous.as(TestPost).slug.should eq("third-post")
    end

    it "returns nil for the first entry" do
      query = TestPostQuery.new
      first = query.all.first

      query.previous(first).should be_nil
    end
  end

  describe "#next" do
    it "returns the next entry in the list" do
      query = TestPostQuery.new
      second = query.find("second-post")
      next_entry = query.next(second)

      next_entry.should_not be_nil
      next_entry.as(TestPost).slug.should eq("first-post")
    end

    it "returns nil for the last entry" do
      query = TestPostQuery.new
      last = query.all.last

      query.next(last).should be_nil
    end
  end

  describe "order_by" do
    it "supports ascending order" do
      posts = TestPostAscQuery.new.all

      posts.first.slug.should eq("first-post")
      posts.last.slug.should eq("third-post")
    end

    it "supports ordering by a different field" do
      posts = TestPostByTitleQuery.new.all

      posts.first.title.should eq("Third post")
      posts.last.title.should eq("Second post")
    end
  end

  describe "frontmatter" do
    it "overrides title from frontmatter" do
      post = TestPostQuery.new.find("first-post")

      post.title.should eq("The very first post")
    end

    it "reads description from frontmatter" do
      post = TestPostQuery.new.find("second-post")

      post.description.should eq("This is the second post.")
    end

    it "handles entries without frontmatter" do
      post = TestPostQuery.new.find("third-post")

      post.title.should eq("Third post")
      post.description.should be_nil
      post.content.should eq("Just a post without frontmatter.")
    end
  end

  describe "content" do
    it "preserves multiline content" do
      post = TestPostQuery.new.find("first-post")

      post.content.should contain("\n")
    end
  end
end
