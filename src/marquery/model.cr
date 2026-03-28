module Marquery
  module Model
    macro included
      include JSON::Serializable

      getter slug : String
      getter title : String
      getter description : String?
      getter content : String
      getter date : Time
      getter active : Bool = false
    end
  end
end
