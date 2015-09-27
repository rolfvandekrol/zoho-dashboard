
module Zoho
  module Data
    class Bug < Base
      parents :portal, :project
      property :title, :closed
      child :log

      def closed?
        closed
      end
    end
  end
end