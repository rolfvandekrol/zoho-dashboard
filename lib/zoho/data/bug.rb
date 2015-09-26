
module Zoho
  module Data
    class Bug < Base
      parents :portal, :project
      property :title
      child :log
    end
  end
end