require 'adrian/queue'

module Adrian
  class ArrayQueue < Queue
    def initialize(array = [])
      @array = array.map { |item| wrap_item(item) }
      @mutex = Mutex.new
    end

    def pop
      @mutex.synchronize { @array.shift }
    end

    def push(item)
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
