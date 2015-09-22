
module Zoho
  autoload :Connection, 'zoho/connection'
  autoload :Downloader, 'zoho/downloader'

  autoload :Data,       'zoho/data'
  autoload :Relation,   'zoho/relation'

  def self.connect(options)
    Zoho::Connection.new(options)
  end
end