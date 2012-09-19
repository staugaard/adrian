require 'adrian/queue'

module Adrian
  class ArrayQueue < Queue
    def initialize(array = [])
      @array = array
      @mutex = Mutex.new
    end

    def pop
      @mutex.synchronize { @array.shift }
    end

    def push(item)
      @mutex.synchronize { @array << item }
    end
  end
end
