# frozen_string_literal: true

require 'active_support/core_ext/class'
require_relative "active_record_extensions"

module StaticModel
  class RecordNotFound < StandardError
  end

  class Base
    include ActiveSupport

    class_attribute :primary_key, instance_accessor: false

    self.primary_key = "id"
    @data = [].freeze

    class << self
      def all
        @data ||= [] # rubocop:disable Naming/MemoizedInstanceVariableName
      end

      def where(attributes)
        @data.select { |record| matches_attributes?(record, attributes) }
      end

      def find_by(attributes)
        @data.find { |record| matches_attributes?(record, attributes) }
      end

      def find_by!(attributes)
        find_by(attributes) || raise(RecordNotFound, "Couldn't find #{name}")
      end

      def find(id)
        if id.is_a?(Array)
          records = where(primary_key => id)
          missing_ids = id - records.map { |r| r.public_send(primary_key) }

          if missing_ids.any?
            raise RecordNotFound, "Couldn't find #{name} with #{primary_key}=#{missing_ids.join(", ")}"
          end

          records
        else
          record = find_by!(primary_key => id)
          raise RecordNotFound, "Couldn't find #{name} with #{primary_key}=#{id}" if record.nil?

          record
        end
      end

      def pluck(attribute)
        @data.map(&attribute)
      end

      private

      def data=(records)
        @data = (records || []).dup.freeze
      end

      def record_accessors(attribute)
        @data.each do |record|
          value = record.public_send(attribute)
          define_singleton_method value.to_s do
            find_by(attribute => value)
          end
        end
      end

      def matches_attributes?(record, attributes=[])
        return true if attributes.nil? || attributes.blank?

        attributes.all? do |key, search_value|
          record_value = record.public_send(key)

          if search_value.is_a?(Array)
            search_value.any? { |sv| values_equal?(record_value, sv) }
          else
            values_equal?(record_value, search_value)
          end
        end
      end

      def values_equal?(record_value, search_value)
        (record_value == search_value) ||
          (record_value.is_a?(Integer) && record_value.to_s == search_value)
      end
    end

    def initialize(attributes = {})
      attributes.each do |name, value|
        instance_variable_set(:"@#{name}", value)
      end
      freeze
    end

    def primary_key
      public_send(self.class.primary_key)
    end

    def eql?(other)
      other.instance_of?(self.class) && !primary_key.nil? && (primary_key == other.primary_key)
    end

    alias == eql?

    def hash
      primary_key.hash
    end
  end
end
