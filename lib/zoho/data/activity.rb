
require 'active_support/core_ext/array/access'
require 'active_support/core_ext/string/inflections'

module Zoho
  module Data
    class Activity < Base
      parents :portal, :project

      def self.class_from_data(data)
        klass_names = data['activity_for'].downcase.split(/[^a-z]+/).reduce([[]]) do |memo, obj|
          memo << memo.last + [obj]
        end.from(1).map{|obj| obj.join('_').camelize }.reverse

        klass_names.each do |klass_name|
          return self.const_get(klass_name) if self.const_defined?(klass_name)
        end
      end

      class Bug < self
        
      end
    end
  end
end