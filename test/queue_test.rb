require_relative 'test_helper'

describe Adrian::Queue do
  class TestQueue < Adrian::Queue
    attr_accessor :item

    def pop_item
      @item
    end

    def push_item(item)
      @item = item
    end
  end

  describe 'when a max age is defined' do
    before { @q = TestQueue.new(:max_age => 60) }

    it 'validates the age of items' do
      item = Adrian::QueueItem.new('value', Time.now)
      @q.push(item)
      @q.pop.must_equal item

      item = Adrian::QueueItem.new('value', Time.now - 120)
      @q.push(item)
      lambda { @q.pop }.must_raise(Adrian::Queue::ItemTooOldError)
    end
  end

end
