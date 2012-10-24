require 'adrian/queue'

module Adrian
  class CompositeQueue < Queue
    def initialize(*queues)
      super()
      @queues = queues.flatten
    end

    def pop
      @queues.each do |q|
        item = q.pop
        return item if item
      end

      nil
    end

    def push(item)
      raise "You can not push item to a composite queue"
    end
  end
end
