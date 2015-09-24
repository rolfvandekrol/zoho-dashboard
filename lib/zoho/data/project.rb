
module Zoho
  module Data
    class Project < Base
      parents :portal
      property :id, :name
    end
  end
end