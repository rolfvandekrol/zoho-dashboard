
module Zoho
  module Data
    class Bug < Base
      parents :portal, :project
      property :title
    end
  end
end