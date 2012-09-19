require 'adrian/queue'

module Adrian
  class ArrayQueue < Queue
    def initialize(array = [])
      @array = array
    end

    def pop
      @array.shift
    end

    def push(item)
      @array << item
    end
  end
end
