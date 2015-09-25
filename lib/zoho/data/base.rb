
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

      def self.relation_from_connection(connection, parents = {})
        Zoho::Relation.new(connection, self, parents)
      end

      def self.paginated?
        @paginated = true if @paginated.nil?
        @paginated
      end

      def self.disable_pagination
        @paginated = false
      end

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

      def self.class_from_data(data)
        self
      end

      def self.from_data(connection, parents, data)
        inst = class_from_data(data).new(connection, parents)
        inst.update_data(data)
        inst
      end

      def self.properties
        @properties ||= []
      end

      def self.property(*props)
        props = Array(props)

        props.each do |prop|
          self.properties << prop.to_sym unless self.properties.include? prop.to_sym

          attr_accessor prop.to_sym
        end
      end

      def self.get_parents
        @parents ||= []
      end

      def self.parents(*parents)
        @parents = Array(parents).map(&:to_sym)
      end

      def data
        @data ||= {}
      end

      def update_data(input)
        input.each do |key, value|
          data[key] = value

          next unless self.class.properties.include? key.to_sym
          send("#{key}=".to_sym, value)
        end
      end
    end
  end
end