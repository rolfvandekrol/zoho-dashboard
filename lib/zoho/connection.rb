
require 'uri'
require 'net/http'
require 'json'

require 'active_support/core_ext/hash/conversions'

module Zoho
  class Connection
    BASE_URL = "https://projectsapi.zoho.com/restapi/"

    def initialize(options)
      @options = options
    end

    def portals
      Zoho::Data::Portal.relation_from_connection(self)
    end

    def get(path, query = {})
      uri = URI.parse(BASE_URL)
      uri.merge! path
      uri.query = query.merge({authtoken: token}).to_query

      response = Net::HTTP.get_response(uri)
      raise unless response.kind_of? Net::HTTPSuccess

      return nil if response.kind_of? Net::HTTPNoContent

      JSON.parse(response.body)
    end

    protected

    def token
      @options[:token]
    end
  end
end