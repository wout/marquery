require "http/server/handler"
require "mime"

module Marquery
  class AssetHandler
    include HTTP::Handler

    @roots : Array(String)

    def initialize(*directories : String)
      @roots = directories.map do |dir|
        expanded = File.expand_path(dir)
        File.exists?(expanded) ? File.realpath(expanded) : expanded
      end.to_a
    end

    def call(context : HTTP::Server::Context) : Nil
      if path = serveable_path(context.request.path.lchop("/"))
        context.response.content_type = MIME.from_filename(path, "application/octet-stream")
        context.response.content_length = File.size(path)
        File.open(path) { |file| IO.copy(file, context.response) }
      else
        call_next(context)
      end
    end

    private def serveable_path(request_path : String) : String?
      return nil if request_path.empty?
      return nil unless File.file?(request_path)

      real = File.realpath(request_path)
      contained = @roots.any? do |root|
        real == root || real.starts_with?(root + File::SEPARATOR)
      end
      contained ? real : nil
    end
  end
end
