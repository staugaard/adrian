require 'adrian/failure_handler'

module Adrian
  class Dispatcher
    attr_reader :running

    def initialize(options = {})
      @failure_handler = FailureHandler.new
      @stop_when_done  = !!options[:stop_when_done]
      @sleep           = options[:sleep] || 0.5
      @options         = options
    end

    def on_failure(*exceptions)
      @failure_handler.add_rule(*exceptions, &Proc.new)
    end

    def on_done
      @failure_handler.add_rule(nil, &Proc.new)
    end

    def start(queue, worker_class)
      @running = true

      while @running do
        if item = queue.pop
          delegate_work(item, worker_class)
        else
          if @stop_when_done
            stop
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

    def work_done(item, worker, exception = nil)
      if handler = @failure_handler.handle(exception)
        handler.call(item, exception)
      else
        raise exception if exception
      end
    end

  end
end
