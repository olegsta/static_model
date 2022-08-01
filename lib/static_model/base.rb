# frozen_string_literal: true

require "active_support/all"
require_relative "active_record_extensions"

module StaticModel
  # StaticModel::RecordNotFound is raised when a record cannot be found.
  class RecordNotFound < StandardError; end

  # Base class for static models.
  class Base
    include ActiveSupport
    include ActiveRecordExtensions

    class_attribute :primary_key, instance_accessor: false
    self.primary_key = "id"
    @data = [].freeze

    class << self
      # Returns all records.
      def all
        @data ||= [] # rubocop:disable Naming/MemoizedInstanceVariableName
      end

      # Finds records based on the provided attributes.
      def where(attributes)
        @data.select { |record| matches_attributes?(record, attributes) }
      end

      # Finds a single record based on the provided attributes.
      def find_by(attributes)
        @data.find { |record| matches_attributes?(record, attributes) }
      end

      # Finds a single record based on the provided attributes, raising an error if not found.
      def find_by!(attributes)
        find_by(attributes) || raise(RecordNotFound, "Couldn't find #{name}")
      end

      # Finds records by ID or an array of IDs.
      def find(id)
        return find_by_ids(id) if id.is_a?(Array)

        find_single_record(id)
      end

      # Plucks a single attribute from all records.
      def pluck(attribute)
        @data.map(&attribute)
      end

      private

      # Sets the data for the class.
      def data=(records)
        @data = (records || []).dup.freeze
      end

      def find_by_ids(ids)
        records = where(primary_key => ids)
        missing_ids = ids - records.map { |r| r.public_send(primary_key) }

        raise_record_not_found(missing_ids) if missing_ids.any?

        records
      end

      def find_single_record(id)
        record = find_by!(primary_key => id)
        raise_record_not_found(id) if record.nil?

        record
      end

      def raise_record_not_found(ids)
        raise RecordNotFound, "Couldn't find #{name} with #{primary_key}=#{ids.join(", ")}"
      end

      # Defines singleton methods for each record's attribute.
      def record_accessors(attribute)
        @data.each do |record|
          value = record.public_send(attribute)
          define_singleton_method value.to_s do
            find_by(attribute => value)
          end
        end
      end

      # Checks if the record matches the provided attributes.
      def matches_attributes?(record, attributes = [])
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

      # Checks if two values are equal.
      def values_equal?(record_value, search_value)
        (record_value == search_value) ||
          (record_value.is_a?(Integer) && record_value.to_s == search_value)
      end
    end

    # Initializes a new instance of the class with the provided attributes.
    def initialize(attributes = {})
      attributes.each do |name, value|
        instance_variable_set(:"@#{name}", value)
      end
      freeze
    end

    # Returns the primary key of the instance.
    def primary_key
      public_send(self.class.primary_key)
    end

    # Checks if two instances are equal.
    def eql?(other)
      other.instance_of?(self.class) && !primary_key.nil? && (primary_key == other.primary_key)
    end

    # Alias for eql? method.
    alias == eql?

    # Returns the hash value of the primary key.
    def hash
      primary_key.hash
    end
  end
end
