
module Zoho
  module Data
    class Project < Base
      parents :portal
      property :id, :name, :link
    end
  end
end