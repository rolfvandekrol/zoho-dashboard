
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
      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)
      return nil if response.kind_of? Net::HTTPNotFound 
      return nil if response.kind_of? Net::HTTPNoContent

      raise unless response.kind_of? Net::HTTPSuccess

      JSON.parse(response.body)
    end

    protected

    def http
      @http ||= begin
        base_uri = URI.parse(BASE_URL)
        http = Net::HTTP.new(base_uri.host, base_uri.port)
        http.use_ssl = true
        http
      end
    end

    def token
      @options[:token]
    end
  end
end