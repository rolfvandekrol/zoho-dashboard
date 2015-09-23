
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/string/inflections'

module Zoho
  class Relation
    include Enumerable

    attr_reader :connection, :klass, :parents

    def initialize(connection, klass, parents = {})
      parents.assert_valid_keys(klass.get_parents)
      raise ArgumentError unless klass.get_parents.all? {|s| parents.key? s}

      @connection = connection
      @klass = klass
      @parents = parents
    end

    def each
      each_pages do |page|
        page.each do |record|
          yield klass.from_data(connection, record)
        end
      end
    end

    protected

    def loaded_pages
      @loaded_pages ||= []
    end

    def last_page_loaded?
      @last_page_loaded ||= false
    end
    def last_page_loaded!
      @last_page_loaded = true
    end

    def path
      r = []

      klass.get_parents.each do |parent|
        parent_klass = "zoho/data/#{parent}".camelize.constantize
        r << parent_klass.member_path
        r << parents[parent]
      end

      r << klass.collection_path

      "#{r.join('/')}/"
    end

    def load_next_page
      unless paginated?
        return load_all_unpaginated
      end

      data = connection.get(path, index: 500, range: 2)
      pp data
      raise
    end

    def each_pages
      loaded_pages.each do |page|
        yield page
      end

      while not last_page_loaded? do
        yield load_next_page
      end
    end

    def load_all_unpaginated
      data = connection.get(path)
      page = data[klass.collection_path]
      loaded_pages << page
      last_page_loaded!
      page
    end

    def paginated?
      klass.paginated?
    end

    def result_range
      50
    end
  end
end