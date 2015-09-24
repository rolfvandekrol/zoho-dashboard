
module Zoho
  module Data
    class Activity < Base
      parents :portal, :project
      property :id
    end
  end
end