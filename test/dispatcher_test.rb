require_relative 'test_helper'

describe Adrian::Dispatcher do
  before do
    $done_items = []
    @q          = Adrian::ArrayQueue.new
    @dispatcher = Adrian::Dispatcher.new(:stop_when_done => true)
    @worker     = TestWorker
  end

  class TestWorker

    def initialize(item)
      @item       = item
      @done_items = []
    end

    def perform
      $done_items << [@boss, @item.value]
    end

    def report_to(boss)
      @boss = boss
    end

  end

  describe "work delegation" do
    it "should instantiate an instance of the worker for each item and ask it to perform" do
      @q.push(1)
      @q.push(2)
      @q.push(3)

      @dispatcher.start(@q, @worker)

      $done_items.must_equal([[@dispatcher, 1], [@dispatcher, 2], [@dispatcher, 3]])
    end
  end

  describe "work evaluation" do

    it "stops when receiving a termination signal" do
      @dispatcher = Adrian::Dispatcher.new(:stop_when_done => false)
      dispatch_thread = Thread.new { @dispatcher.start(@q, @worker) }
      sleep(0.1)
      assert_equal true, @dispatcher.running

      Process.kill('TERM', Process.pid)
      assert_equal false, @dispatcher.running
      dispatch_thread.exit
    end

    it "should use the failure handler to handle the result" do
      @dispatcher.on_failure(RuntimeError) do |item, worker, exception|
        @q.push(item)
      end

      @dispatcher.work_done(1, nil)
      @q.pop.must_be_nil

      @dispatcher.work_done(1, nil, nil)
      @q.pop.must_be_nil

      @dispatcher.work_done(1, nil, RuntimeError.new)
      @q.pop.value.must_equal 1
    end
  end
end
