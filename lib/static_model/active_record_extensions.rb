# frozen_string_literal: true

module StaticModel
  module ActiveRecordExtensions
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
