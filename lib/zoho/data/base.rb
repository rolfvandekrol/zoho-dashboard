
require 'active_support/core_ext/string/inflections'

module Zoho
  module Data
    class Base
      attr_reader :connection
      attr_reader :parents

      def initialize(connection, parents = {})
        @connection = connection
        @parents = parents
      end

      def data
        @data ||= {}
      end

      # Pagination
      def self.paginated?
        @paginated = true if @paginated.nil?
        @paginated
      end
      def self.disable_pagination
        @paginated = false
      end

      # Paths
      def self.has_member_path?
        @has_member_path = true if @has_member_path.nil?
        @has_member_path
      end
      def self.disable_member_path
        @has_member_path = false
      end
      def self.collection_path
        self.name.demodulize.underscore.pluralize
      end
      def self.member_path
        self.collection_path
      end

      # Instance generation from data array
      def self.class_from_data(data)
        self
      end
      def self.from_data(connection, parents, data)
        inst = class_from_data(data).new(connection, parents)
        inst.update_data(data)
        inst
      end
      def update_data(input)
        input.each do |key, value|
          data[key] = value

          next unless self.class.properties.include? key.to_sym
          send("#{key}=".to_sym, value)
        end
      end

      # Properties
      def self.properties
        if superclass.respond_to? :properties
          return superclass.properties + own_properties
        end

        [] + own_properties
      end

      def self.own_properties
        @properties ||= []
      end
      def self.property(*props)
        props = Array(props)

        props.each do |prop|
          self.own_properties << prop.to_sym unless self.properties.include? prop.to_sym

          attr_accessor prop.to_sym
        end
      end

      # Parents
      def self.get_parents
        return @parents unless @parents.nil?

        if superclass.respond_to? :get_parents
          return superclass.get_parents
        end

        []
      end
      def self.parents(*parents)
        @parents = Array(parents).map(&:to_sym)
      end

      def self.child(*children)
        children.each do |ch|
          klass = Zoho::Data.const_get(ch.to_s.camelize.to_sym)
          parents_key = self.name.demodulize.underscore.to_sym

          define_method(ch.to_s.pluralize.to_sym) do
            klass.relation_from_connection(connection, parents.merge({parents_key => id}))
          end
        end
      end

      # Relation
      def self.relation_from_connection(connection, parents = {})
        Zoho::Relation.new(connection, self, parents)
      end

      property :id
    end
  end
end