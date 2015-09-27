
module Zoho
  autoload :Connection, 'zoho/connection'

  autoload :Data,       'zoho/data'
  autoload :Relation,   'zoho/relation'

  def self.connect(options)
    Zoho::Connection.new(options)
  end
end