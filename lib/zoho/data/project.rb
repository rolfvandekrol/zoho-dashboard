
module Zoho
  module Data
    class Project < Base
      parents :portal
      property :name, :link, :group_id
      child :activity, :bug
    end
  end
end