require_relative 'test_helper'

describe Adrian::Dispatcher do
  before do
    $done_items = []
    @q = Adrian::ArrayQueue.new
    @dispatcher = Adrian::Dispatcher.new(:stop_when_done => true)
    @dispatcher.add_queue(:q, @q)
  end

  describe "work delegation" do
    it "should instantiate an instance of the worker for each item and ask it to perform" do
      worker = Class.new do
        def initialize(item)
          @item = item
        end

        def perform
          $done_items << [@boss, @item]
        end

        def report_to(boss)
          @boss = boss
        end
      end

      @q.push(1)
      @q.push(2)
      @q.push(3)

      @dispatcher.start(:q, worker)

      $done_items.must_equal([[@dispatcher, 1], [@dispatcher, 2], [@dispatcher, 3]])
    end
  end

  describe "work evaluation" do
    it "should use the requeuer to route the result" do
      @dispatcher.requeue_on_failure(:q, RuntimeError)

      @dispatcher.work_done(1)
      @q.pop.must_be_nil

      @dispatcher.work_done(1, nil)
      @q.pop.must_be_nil

      @dispatcher.work_done(1, RuntimeError.new)
      @q.pop.must_equal 1
    end
  end
end
