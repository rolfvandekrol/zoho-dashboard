
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
          yield klass.from_data(connection, parents, record)
        end
      end
    end

    def find_by_id(id)
      unless has_member_path?
        return find do |obj|
          id == obj.id
        end
      end

      data = connection.get(member_path(id))
      return nil if data.nil?

      record = data[klass.collection_path].first
      return klass.from_data(connection, parents, record)
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

    def parents_path_components
      r = []

      klass.get_parents.each do |parent|
        parent_klass = "zoho/data/#{parent}".camelize.constantize
        r << parent_klass.member_path
        r << parents[parent]
      end

      r
    end

    def collection_path
      r = parents_path_components
      r << klass.collection_path
      "#{r.join('/')}/"
    end

    def member_path(id)
      r = parents_path_components
      r << klass.member_path
      r << id.to_s
      "#{r.join('/')}/"
    end

    def load_next_page
      unless paginated?
        return load_all_unpaginated
      end

      data = connection.get(collection_path, index: loaded_pages.length * result_range + 1, range: result_range)
      if data.nil?
        last_page_loaded!
        return nil
      end

      page = data[klass.collection_path]
      loaded_pages << page
      if page.length < result_range
        last_page_loaded!
      end

      page
    end

    def each_pages
      loaded_pages.each do |page|
        yield page
      end

      while not last_page_loaded? do
        next_page = load_next_page
        yield next_page unless next_page.nil?
      end
    end

    def load_all_unpaginated
      data = connection.get(collection_path)
      page = data[klass.collection_path]
      loaded_pages << page
      last_page_loaded!
      page
    end

    def paginated?
      klass.paginated?
    end

    def has_member_path?
      klass.has_member_path?
    end

    def result_range
      10
    end
  end
end