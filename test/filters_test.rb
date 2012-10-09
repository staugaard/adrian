require_relative 'test_helper'
require 'tempfile'
require 'tmpdir'


describe Adrian::Filters do
  before do
    @q    = Object.new.extend(Adrian::Filters)
    @item = Adrian::QueueItem.new("hello")
  end

  class FakeFilter

    def initialize(options = {})
      @allow = options.fetch(:allow)
    end

    def allow?(item)
      @allow == true
    end

  end

  describe "#filter?" do

    it "is true when any filter denies the item" do
      @q.filters << FakeFilter.new(:allow => true)
      @q.filters << FakeFilter.new(:allow => false)

      assert_equal true, @q.filter?(@item)
    end

    it "is false when all filters allow the item" do
      @q.filters << FakeFilter.new(:allow => true)
      assert_equal false, @q.filter?(@item)
    end

  end

  module Updatable
    attr_accessor :updated_at
  end

  describe Adrian::Filters::Delay do
    before do
      @filter          = Adrian::Filters::Delay.new
      @updatable_item  = Adrian::QueueItem.new("hello")
      @updatable_item.extend(Updatable)
      @updatable_item.updated_at = Time.new
      @fifteen_minutes = 900
    end

    it "allows items that have not been recently updated" do
      Time.stub(:new, @updatable_item.updated_at + @fifteen_minutes) do
        assert_equal true, @filter.allow?(@updatable_item)
      end
    end

    it "denies items that have been recently updated" do
      assert_equal false, @filter.allow?(@updatable_item)
    end

    it "has a configurable recently updated duration that defaults to 15 minutes" do
      assert_equal @fifteen_minutes, @filter.duration
      configured_filter = Adrian::Filters::Delay.new(:duration => 1)

      assert_equal 1, configured_filter.duration
    end

  end

  describe Adrian::Filters::FileLock do
    before do
      @filter         = Adrian::Filters::FileLock.new(:reserved_path => 'path/to/locked')
      @available_item = Adrian::FileItem.new("path/to/file")
      @locked_item    = Adrian::FileItem.new("path/to/locked/file")
      @one_hour       = 3_600
    end

    it "allows items that are not locked" do
      assert_equal true, @filter.allow?(@available_item)
    end

    it "allows items with an expired lock" do
      @locked_item.stub(:updated_at, Time.new - @one_hour) do
        assert_equal true, @filter.allow?(@locked_item)
      end
    end

    it "does not allow items with a fresh lock" do
      @locked_item.stub(:updated_at, Time.new) do
        assert_equal false, @filter.allow?(@locked_item)
      end
    end

    it "has a configurable lock expiry duration that defaults to one hour" do
      assert_equal @one_hour, @filter.duration
      configured_filter = Adrian::Filters::FileLock.new(:duration => 1, :reserved_path => 'path/to/locked')

      assert_equal 1, configured_filter.duration
    end

  end

end
