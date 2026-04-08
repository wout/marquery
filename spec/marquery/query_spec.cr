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

  describe "#first" do
    it "returns the first entry" do
      TestPostQuery.new.first.slug.should eq("third-post")
    end
  end

  describe "#first?" do
    it "returns the first entry" do
      TestPostQuery.new.first?.try(&.slug).should eq("third-post")
    end

    it "returns nil when no entries match" do
      TestPostQuery.new.filter { false }.first?.should be_nil
    end
  end

  describe "#last" do
    it "returns the last entry" do
      TestPostQuery.new.last.slug.should eq("first-post")
    end
  end

  describe "#last?" do
    it "returns the last entry" do
      TestPostQuery.new.last?.try(&.slug).should eq("first-post")
    end

    it "returns nil when no entries match" do
      TestPostQuery.new.filter { false }.last?.should be_nil
    end
  end

  describe "#shuffle" do
    it "returns self" do
      query = TestPostQuery.new

      query.shuffle.should be(query)
    end

    it "contains all entries" do
      slugs = TestPostQuery.new.shuffle.all.map(&.slug).sort!

      slugs.should eq(["first-post", "second-post", "third-post"])
    end

    it "accepts a custom random generator" do
      slugs = TestPostQuery.new.shuffle(Random.new(42)).all.map(&.slug)

      slugs.should eq(TestPostQuery.new.shuffle(Random.new(42)).all.map(&.slug))
    end
  end

  describe "#reverse" do
    it "returns self" do
      query = TestPostQuery.new

      query.reverse.should be(query)
    end

    it "reverses the entry order" do
      posts = TestPostQuery.new.reverse.all

      posts.first.slug.should eq("first-post")
      posts.last.slug.should eq("third-post")
    end
  end

  describe "#sort_by" do
    it "returns self" do
      query = TestPostQuery.new

      query.sort_by(&.title).should be(query)
    end

    it "sorts entries by the given field" do
      posts = TestPostQuery.new.sort_by(&.title).all

      posts.first.title.should eq("Second post")
      posts.last.title.should eq("Third post")
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

  describe "#filter" do
    it "filters entries with a block" do
      posts = TestPostQuery.new.filter(&.active?).all

      posts.size.should eq(2)
      posts.map(&.slug).should_not contain("first-post")
    end

    it "is chainable" do
      posts = TestPostQuery.new
        .filter { |post| !post.active? }
        .filter { |post| post.date <= Time.local(2026, 3, 21) }
        .all

      posts.size.should eq(1)
      posts.first.slug.should eq("first-post")
    end

    it "returns self" do
      query = TestPostQuery.new

      query.filter(&.active?).should be(query)
    end
  end

  describe "chaining" do
    it "chains filter, sort_by, and reverse" do
      posts = TestPostQuery.new
        .filter(&.active?)
        .sort_by(&.title)
        .reverse
        .all

      posts.size.should eq(2)
      posts.first.title.should eq("Third post")
      posts.last.title.should eq("Second post")
    end

    it "chains shuffle and filter" do
      posts = TestPostQuery.new
        .shuffle
        .filter(&.active?)
        .all

      posts.size.should eq(2)
      posts.none?(&.slug.==("first-post")).should be_true
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

    it "reads array values from frontmatter" do
      post = TestPostQuery.new.find("second-post")

      post.tags.should eq(["crystal", "web"])
    end

    it "defaults array fields to empty" do
      post = TestPostQuery.new.find("third-post")

      post.tags.should be_empty
    end
  end

  describe "filtering on arrays" do
    it "filters by tag" do
      posts = TestPostQuery.new
        .filter(&.tags.includes?("crystal"))
        .all

      posts.size.should eq(1)
      posts.first.slug.should eq("second-post")
    end
  end

  describe ".dir" do
    it "returns the data directory path" do
      TestPostQuery.dir.should eq("marquery/test_post")
    end
  end

  describe ".index" do
    it "parses _index.md with frontmatter and content" do
      index = TestPostQuery.index

      index.title.should eq("Test Blog")
      index.description.should eq("A test blog for specs")
      index.content.should eq("Welcome to the test blog.")
      index.to_html.should contain("<p>Welcome to the test blog.</p>")
    end

    it "supports custom collection models" do
      TestPostCustomIndexQuery.index.subtitle.should eq("Crystal all the things")
    end
  end

  describe "content" do
    it "preserves multiline content" do
      post = TestPostQuery.new.find("first-post")

      post.content.should contain("\n")
    end
  end

  describe "source" do
    it "includes the source file path" do
      post = TestPostQuery.new.find("first-post")

      post.source.should eq("./marquery/test_post/20260320_first_post.md")
    end
  end
end
