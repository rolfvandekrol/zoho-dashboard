
module Zoho
  module Data
    class Project < Base
      parents :portal
      property :name, :link

      def activities
        Zoho::Data::Activity.relation_from_connection(connection, parents.merge({project: id}))
      end
      def bugs
        Zoho::Data::Bug.relation_from_connection(connection, parents.merge({project: id}))
      end
    end
  end
end