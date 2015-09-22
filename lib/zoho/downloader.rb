
module Zoho
  class Downloader
    def initialize(options)
      @options = options
    end

    def run
      p connection.portals.first.projects.to_a
      # p Hash[connection.portals.to_a.map{|portal| [portal.id, [portal.name, portal.company_name]] }]
    end

    protected

    def connection
      @connection ||= Zoho.connect(@options)
    end
  end
end