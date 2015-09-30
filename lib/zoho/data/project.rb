
module Zoho
  module Data
    class Project < Base
      parents :portal
      property :name, :link, :group_id, :group_name
      child :activity, :bug
    end
  end
end