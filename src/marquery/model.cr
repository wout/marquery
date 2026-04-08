module Marquery
  module Model
    macro included
      include JSON::Serializable
      include ::Marquery::Renderable

      getter slug : String
      getter title : String
      getter description : String?
      getter content : String
      getter date : Time
      getter? active : Bool = true
    end
  end
end
