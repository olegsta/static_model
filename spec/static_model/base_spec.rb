# frozen_string_literal: true

require "spec_helper"
require "byebug"

describe StaticModel::Base do # < ActiveSupport::TestCase
  let(:united_states) { StaticCountry.new(name: "United States", iso_code: "US", language: "English") }
  let(:canada) { StaticCountry.new(name: "Canada", iso_code: "CA", language: "English") }
  let(:mexico) { StaticCountry.new(name: "Mexico", iso_code: "MX", language: "Spanish") }

  let(:european_union) { StaticRegion.new(name: "European Union", iso_code: "EU", description: "A union of Europeans") }

  class VerificationError < StandardError
  end

  def assert(bool, message = nil)
    raise VerificationError, message unless bool
  end

  def assert_equal(expected, actual)
    expect(expected).to eq(actual)
  end

  def assert_same_elements(expected, actual)
    expect(expected).to eq(actual)
  end

  def assert_not_equal(expected, actual)
    expect(expected).not_to eq(actual)
  end

  def assert_not_operator(expected, _operator, actual)
    expect(expected).to have_attributes(actual)
  end

  before do
    class StaticThing < StaticModel::Base
      attr_reader :id, :name
    end

    class StaticCountry < StaticModel::Base
      self.primary_key = "iso_code"
      attr_reader :name, :iso_code, :language
    end

    class StaticRegion < StaticCountry
      attr_reader :description
    end
  end

  # after do
  #   StaticModel::Base.send :remove_const, :StaticRegion
  #   StaticModel::Base.send :remove_const, :StaticCountry
  #   StaticModel::Base.send :remove_const, :StaticThing
  # end

  describe ".new" do
    it "assigns attributes" do
      assert_equal "United States", united_states.name
      assert_equal "US", united_states.iso_code
    end

    it "freezes the record" do
      assert_equal true, united_states.frozen?
    end
  end

  describe ".data=" do
    it "stores the records" do
      StaticCountry.send(:data=, [united_states, canada])
      assert_same_elements [united_states, canada], StaticCountry.all
    end

    it "stores a copy of the original collection" do
      countries = [united_states, canada]
      StaticCountry.send(:data=, countries)
      assert_not StaticCountry.all.equal?(countries)
    end

    it "allows each subclass to have its own data" do
      StaticCountry.send(:data=, [united_states])
      StaticRegion.send(:data=, [european_union])

      assert_same_elements [united_states], StaticCountry.all
      assert_same_elements [european_union], StaticRegion.all
    end

    it "replaces any existing data" do
      StaticCountry.send(:data=, [united_states])
      StaticCountry.send(:data=, [canada])
      assert_same_elements [canada], StaticCountry.all
    end
  end

  describe ".all" do
    it "returns an empty array if data is not set" do
      assert_equal [], StaticCountry.all
    end

    it "returns an empty array if data is nil" do
      StaticCountry.send(:data=, nil)
      assert_equal [], StaticCountry.all
    end
  end

  describe ".where" do
    before do
      StaticCountry.send(:data=, [united_states, canada, mexico])
    end

    it "raises ArgumentError if no conditions are provided" do
      assert_raises(ArgumentError) do
        StaticCountry.where
      end
    end

    it "returns all records when passed nil" do
      assert_equal StaticCountry.all, StaticCountry.where(nil)
    end

    it "returns all records when passed an empty hash" do
      assert_equal StaticCountry.all, StaticCountry.where({})
    end

    it "filters the records from a AR-like conditions hash" do
      assert_same_elements [united_states, canada], StaticCountry.where(language: "English")
    end

    it "accepts arrays of values" do
      assert_same_elements [canada, mexico], StaticCountry.where(iso_code: %w[CA MX])
    end

    it "returns an empty array when no records are found" do
      assert_same_elements [], StaticCountry.where(language: "Greek")
    end
  end

  describe ".find_by" do
    before do
      StaticCountry.send(:data=, [united_states, canada, mexico])
    end

    it "raises ArgumentError if no conditions are provided" do
      assert_raises(ArgumentError) do
        StaticCountry.find_by
      end
    end

    it "returns the first record when passed nil" do
      assert_equal StaticCountry.all.first, StaticCountry.find_by(nil)
    end

    it "returns the first record when passed an empty hash" do
      assert_equal StaticCountry.all.first, StaticCountry.find_by({})
    end

    it "finds a record from a AR-like conditions hash" do
      assert_equal united_states, StaticCountry.find_by(language: "English")
    end

    it "accepts arrays of values" do
      assert_equal canada, StaticCountry.find_by(iso_code: %w[CA MX])
    end

    it "returns nil when no record is found" do
      assert_nil StaticCountry.find_by(language: "Greek")
    end
  end

  describe ".find_by!" do
    before do
      StaticCountry.send(:data=, [united_states, canada, mexico])
    end

    it "returns the record if one is found" do
      assert_equal united_states, StaticCountry.find_by!(language: "English")
    end

    it "raises RecordNotFound when no record is found" do
      assert_raises(StaticModel::RecordNotFound) do
        StaticCountry.find_by!(language: "Greek")
      end
    end
  end

  describe ".find" do
    let(:thing_1) { StaticThing.new(id: 1, name: "Thing 1") }
    let(:thing_2) { StaticThing.new(id: 2, name: "Thing 2") }
    let(:thing_3) { StaticThing.new(id: 3, name: "Thing 3") }

    before do
      StaticThing.send(:data=, [thing_1, thing_2, thing_3])
      StaticCountry.send(:data=, [united_states, canada, mexico])
    end

    it "finds the record with the matching primary key" do
      assert_equal canada, StaticCountry.find("CA")
    end

    it "raises RecordNotFound when no record is found" do
      assert_raises(StaticModel::RecordNotFound) do
        StaticCountry.find("GR")
      end
    end

    it "finds all records when given an array of ids" do
      assert_same_elements [canada, mexico], StaticCountry.find(%w[CA MX])
    end

    it "raises RecordNotFound when any record is not found" do
      assert_raises(StaticModel::RecordNotFound) do
        StaticCountry.find(%w[CA GR])
      end
    end

    it "finds an integer id when searching with a string" do
      assert_equal thing_2, StaticThing.find("2")
    end
  end

  describe "#eql?" do
    it "should return true with the same class and primary key" do
      assert StaticCountry.new(iso_code: "AA").eql?(StaticCountry.new(iso_code: "AA"))
    end

    it "should return false with the same class and different primary keys" do
      assert_not StaticCountry.new(iso_code: "AA").eql?(StaticCountry.new(iso_code: "BB"))
    end

    it "should return false with the different classes and the same primary key" do
      assert_not StaticCountry.new(iso_code: "AA").eql?(StaticRegion.new(iso_code: "AA"))
    end

    it "returns false when primary key is nil" do
      assert_not StaticCountry.new.eql?(StaticCountry.new)
    end
  end

  describe "#==" do
    it "should return true with the same class and id" do
      assert_operator StaticCountry.new(iso_code: "AA"), :==, StaticCountry.new(iso_code: "AA")
    end

    it "should return false with the same class and different ids" do
      assert_not_equal StaticCountry.new(iso_code: "AA"), StaticCountry.new(iso_code: "BB")
    end

    it "should return false with the different classes and the same id" do
      assert_not_equal StaticCountry.new(iso_code: "AA"), StaticRegion.new(iso_code: "AA")
    end

    it "returns false when id is nil" do
      assert_not_equal StaticCountry.new, StaticCountry.new
    end
  end

  describe "#hash" do
    it "returns id for hash" do
      assert_equal "US".hash, StaticCountry.new(iso_code: "US").hash
      assert_equal nil.hash, StaticCountry.new.hash
    end

    it "is hashable" do
      assert_equal({ StaticCountry.new(iso_code: "AA") => "bar" }, { StaticCountry.new(iso_code: "AA") => "bar" })
      assert_not_equal({ StaticCountry.new(iso_code: "BB") => "bar" }, { StaticCountry.new(iso_code: "AA") => "bar" })
    end
  end
end
