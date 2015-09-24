
module Zoho
  module Data
    class Bug < Base
      parents :portal, :project
      property :id
    end
  end
end