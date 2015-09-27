
module Zoho
  module Data
    class Portal < Base
      disable_pagination
      disable_member_path
      property :settings, :name
      child :project, :user

      def self.member_path
        'portal'
      end

      def company_name
        settings['company_name']
      end
    end
  end
end