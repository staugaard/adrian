module Adrian
  class Dispatcher
    attr_reader :running

    def initialize(options = {})
      @queues         = {}
      @stop_when_done = !!options[:stop_when_done]
      @sleep          = options[:sleep] || 0.5
    end

    def add_queue(name, queue)
      @queues[name.to_sym] = queue
    end

    def start(queue_name, worker_class)
      @running = true

      queue = @queues[queue_name.to_sym]

      while @running do
        if item = queue.pop
          delegate_work(item, worker_class)
        else
          if @stop_when_done
            @running = false
          else
            sleep(@sleep) if @sleep
          end
        end
      end
    end

    def stop
      @running = false
    end

    def delegate_work(item, worker_class)
      worker = worker_class.new(item)
      worker.report_to(self)
      worker.perform
    end

    def work_done(worker, item, exception = nil)
      puts "worker completed #{item.inspect}. #{exception.inspect}"
    end
  end
end
