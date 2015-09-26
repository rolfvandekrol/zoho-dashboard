
module Zoho
  module Data
    class Project < Base
      parents :portal
      property :name, :link
      child :activity, :bug
    end
  end
end