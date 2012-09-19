require_relative 'test_helper'

describe Adrian::Dispatcher do
  before do
    $done_items = []
    @q = Adrian::ArrayQueue.new([1,2,3])
    @dispatcher = Adrian::Dispatcher.new(:stop_when_done => true)
    @dispatcher.add_queue(:source, @q)
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

      @dispatcher.start(:source, worker)

      $done_items.must_equal([[@dispatcher, 1], [@dispatcher, 2], [@dispatcher, 3]])
    end
  end
end
