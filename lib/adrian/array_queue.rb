require 'adrian/queue'

module Adrian
  class ArrayQueue < Queue
    def initialize(array = [], options = {})
      super(options)
      @array = array.map { |item| wrap_item(item) }
      @mutex = Mutex.new
    end

    def pop_item
      @mutex.synchronize { @array.shift }
    end

    def push_item(item)
      item = wrap_item(item)
      @mutex.synchronize { @array << item }
      self
    end

    protected

    def wrap_item(item)
      item.is_a?(QueueItem) ? item : QueueItem.new(item)
    end
  end
end
