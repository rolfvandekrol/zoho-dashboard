
module Zoho
  module Data
    class User < Base
      disable_pagination
      disable_member_path
      
      parents :portal
      property :name, :email, :role
    end
  end
end