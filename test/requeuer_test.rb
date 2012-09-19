require_relative 'test_helper'

require 'adrian/requeuer'

describe Adrian::Requeuer do
  before do
    @requeuer = Adrian::Requeuer.new
    @requeuer.add_rule(:runtime, RuntimeError)
    @requeuer.add_rule(:standard, StandardError)
  end

  it "should match rules in the order they were added" do
    @requeuer.route(RuntimeError.new).must_equal :runtime
    @requeuer.route(StandardError.new).must_equal :standard
  end

  it "should return nil when no rules match" do
    @requeuer.route(Exception.new).must_be_nil
    @requeuer.route(nil).must_be_nil
  end

  describe "the success rule" do
    before { @requeuer.add_rule(:success, nil)}

    it "should match when there is no exception" do
      @requeuer.route(Exception.new).must_be_nil
      @requeuer.route(nil).must_equal :success
    end
  end

end
