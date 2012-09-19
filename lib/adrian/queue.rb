module Adrian
  class Queue
    def pop
      raise "#{self.class.name}#pop is not defined"
    end

    def push
      raise "#{self.class.name}#push is not defined"
    end
  end
end
