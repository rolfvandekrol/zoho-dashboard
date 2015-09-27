
module Zoho
  module Data
    class Bug < Base
      parents :portal, :project
      property :title, :closed
      time_property :created_time
      child :log

      def closed?
        closed
      end
    end
  end
end