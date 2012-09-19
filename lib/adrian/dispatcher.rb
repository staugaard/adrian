require 'adrian/requeuer'

module Adrian
  class Dispatcher
    attr_reader :running

    def initialize(options = {})
      @queues         = {}
      @requeuer       = Requeuer.new
      @stop_when_done = !!options[:stop_when_done]
      @sleep          = options[:sleep] || 0.5
    end

    def add_queue(name, queue)
      @queues[name.to_sym] = queue
    end

    def requeue_on_failure(queue_name, *exceptions)
      raise "Unknown queue name #{queue_name}" unless @queues.has_key?(queue_name.to_sym)
      @requeuer.add_rule(queue_name.to_sym, *exceptions)
    end

    def requeue_on_done(queue_name)
      requeue_on_failure(queue_name, nil)
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

    def work_done(item, exception = nil)
      if queue_name = @requeuer.route(exception)
        @queues[queue_name].push(item)
      end
    end

  end
end
