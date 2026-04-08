module Marquery
  module Collection
    macro included
      include JSON::Serializable
      include ::Marquery::Renderable

      getter title : String = ""
      getter description : String?

      def initialize
      end
    end
  end
end
