module Marquery
  class Error < Exception; end

  class EntryNotFound < Error
    def initialize(slug : String)
      super("Entry not found: #{slug}")
    end
  end

  class AssetNotFound < Error
    def initialize(name : String)
      super("Asset not found: #{name}")
    end
  end
end
