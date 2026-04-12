require "../spec_helper"
require "http/server"

private def call_handler(handler : HTTP::Handler, path : String)
  io = IO::Memory.new
  request = HTTP::Request.new("GET", path)
  response = HTTP::Server::Response.new(io)
  context = HTTP::Server::Context.new(request, response)

  fell_through = false
  handler.next = ->(_context : HTTP::Server::Context) do
    fell_through = true
    nil
  end

  handler.call(context)
  response.close

  {context, io.to_s, fell_through}
end

describe Marquery::AssetHandler do
  describe "#call" do
    it "serves a file inside a configured directory" do
      handler = Marquery::AssetHandler.new("marquery/test_post_assets")
      context, body, fell_through = call_handler(
        handler,
        "/marquery/test_post_assets/_shared/logo.svg"
      )

      fell_through.should be_false
      body.should contain(File.read("marquery/test_post_assets/_shared/logo.svg"))
      context.response.headers["Content-Type"].should eq("image/svg+xml")
    end

    it "supports multiple configured directories" do
      handler = Marquery::AssetHandler.new(
        "marquery/test_post_assets",
        "marquery/test_post_shared_asset",
      )

      _, _, ft1 = call_handler(handler, "/marquery/test_post_assets/_shared/logo.svg")
      _, _, ft2 = call_handler(handler, "/marquery/test_post_shared_asset/20260320_first_post/local.png")

      ft1.should be_false
      ft2.should be_false
    end

    it "falls through for files outside the configured directories" do
      handler = Marquery::AssetHandler.new("marquery/test_post_assets")
      _, _, fell_through = call_handler(
        handler,
        "/marquery/test_post/20260320_first_post.md"
      )

      fell_through.should be_true
    end

    it "falls through for nonexistent files" do
      handler = Marquery::AssetHandler.new("marquery/test_post_assets")
      _, _, fell_through = call_handler(
        handler,
        "/marquery/test_post_assets/does-not-exist.png"
      )

      fell_through.should be_true
    end

    it "falls through for directories" do
      handler = Marquery::AssetHandler.new("marquery/test_post_assets")
      _, _, fell_through = call_handler(
        handler,
        "/marquery/test_post_assets/_shared"
      )

      fell_through.should be_true
    end

    it "rejects path traversal that escapes a configured directory" do
      handler = Marquery::AssetHandler.new("marquery/test_post_assets")
      _, _, fell_through = call_handler(
        handler,
        "/marquery/test_post_assets/../test_post/20260320_first_post.md"
      )

      fell_through.should be_true
    end

    it "falls through for an empty path" do
      handler = Marquery::AssetHandler.new("marquery/test_post_assets")
      _, _, fell_through = call_handler(handler, "/")

      fell_through.should be_true
    end
  end
end
