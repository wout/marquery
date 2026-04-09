require "http/server/handler"
require "mime"

module Marquery
  class AssetHandler
    include HTTP::Handler

    @directories : Array(String)

    def initialize(*directories : String)
      @directories = directories.to_a
    end

    def call(context : HTTP::Server::Context) : Nil
      request_path = context.request.path.lchop("/")
      expanded = File.expand_path(request_path)

      if serveable?(request_path, expanded)
        context.response.content_type = MIME.from_filename(request_path, "application/octet-stream")
        context.response.content_length = File.size(expanded)
        File.open(expanded) { |file| IO.copy(file, context.response) }
      else
        call_next(context)
      end
    end

    private def serveable?(request_path : String, expanded : String) : Bool
      @directories.any? { |dir| request_path.starts_with?(dir) } &&
        expanded.starts_with?(::Dir.current) &&
        File.file?(expanded)
    end
  end
end
