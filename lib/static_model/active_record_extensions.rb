# frozen_string_literal: true

module StaticModel
  # This module provides extensions for ActiveRecord models related to static models.
  module ActiveRecordExtensions
    def self.included(base)
      base.extend(ClassMethods)
      # base.include(InstanceMethods)
    end

    # This module contains class-level methods to extend the functionality of ActiveRecord models.
    module ClassMethods
      # Adds a belongs_to association to a static model.
      #
      # @param association_name [Symbol] The name of the association.
      # @param options [Hash] Additional options for the association.
      #   - :class_name [String] The name of the associated class.
      #   - :foreign_key [Symbol] The name of the foreign key.
      #   - :primary_key [Symbol] The name of the primary key.
      def belongs_to_static_model(association_name, options = {})
        memory_model_klass = (options[:class_name] || association_name.to_s.camelize).constantize
        foreign_key_method = options[:foreign_key] || association_name.to_s.foreign_key
        primary_key_method = options[:primary_key] || memory_model_klass.primary_key

        define_method(association_name) do
          memory_model_klass.find_by(primary_key_method => public_send(foreign_key_method))
        end

        define_method("#{association_name}=") do |value|
          public_send("#{foreign_key_method}=", value&.public_send(primary_key_method))
        end
      end
    end
  end
end
