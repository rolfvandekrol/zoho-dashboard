
module Zoho
  module Data
    class Portal < Base
      disable_pagination
      disable_member_path
      property :settings, :name

      def self.member_path
        'portal'
      end

      def company_name
        settings['company_name']
      end

      def projects
        Zoho::Data::Project.relation_from_connection(connection, {portal: id})
      end
    end
  end
end