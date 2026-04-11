require "../spec_helper"

describe "shared assets" do
  describe "_shared directory" do
    it "makes shared assets available on all entries" do
      posts = TestPostSharedAssetQuery.new.all

      posts.each do |post|
        post.asset?("logo.svg").should_not be_nil
      end
    end

    it "only provides _shared assets when no date match exists" do
      post = TestPostSharedAssetQuery.new.find("third-post")

      post.assets.size.should eq(1)
    end
  end

  describe "date-based directory" do
    it "adds date-specific assets to matching entries" do
      post = TestPostSharedAssetQuery.new.find("second-post")

      post.asset?("banner.jpg").should_not be_nil
    end

    it "does not leak date-specific assets to other entries" do
      post = TestPostSharedAssetQuery.new.find("third-post")

      post.asset?("hero.png").should be_nil
      post.asset?("banner.jpg").should be_nil
    end
  end

  describe "per-entry directory" do
    it "adds per-entry assets" do
      post = TestPostSharedAssetQuery.new.find("first-post")

      post.asset?("local.png").should_not be_nil
    end
  end

  describe "precedence" do
    it "date-based assets override shared assets with the same name" do
      post = TestPostSharedAssetQuery.new.find("second-post")

      post.asset("logo.svg").should eq("/marquery/test_post_assets/_shared/logo.svg")

      first_post = TestPostSharedAssetQuery.new.find("first-post")

      first_post.asset("logo.svg").should eq("/marquery/test_post_assets/20260320/logo.svg")
    end

    it "per-entry assets override date-based assets with the same name" do
      post = TestPostSharedAssetQuery.new.find("first-post")

      post.asset("hero.png").should eq(
        "/marquery/test_post_shared_asset/20260320_first_post/hero.png"
      )
    end

    it "falls back to shared for entries without a date-level override" do
      post = TestPostSharedAssetQuery.new.find("third-post")

      post.asset("logo.svg").should eq("/marquery/test_post_assets/_shared/logo.svg")
    end
  end

  describe "#asset" do
    it "raises AssetNotFound for missing assets" do
      post = TestPostSharedAssetQuery.new.find("third-post")

      expect_raises(Marquery::AssetNotFound, "Asset not found: missing.png") do
        post.asset("missing.png")
      end
    end
  end

  describe ".assets_dir" do
    it "returns the shared assets directory" do
      TestPostSharedAssetQuery.assets_dir.should eq("marquery/test_post_assets")
    end

    it "returns nil when no annotation is set" do
      TestPostQuery.assets_dir.should be_nil
    end
  end
end
