module Marquery
  class Error < Exception; end

  class EntryNotFound < Error
    def initialize(slug : String)
      super("Entry not found: #{slug}")
    end
  end
end
