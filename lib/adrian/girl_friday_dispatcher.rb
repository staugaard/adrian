require 'girl_friday'

module Adrian
  class GirlFridayDispatcher < Dispatcher
    def gf_queue_name
      @options[:name] || 'adrian_queue'
    end

    def gf_queue_size
      @options[:size]
    end

    def gf_queue
      @gf_queue ||= GirlFriday::WorkQueue.new(gf_queue_name, :size => gf_queue_size) do |item, worker_class|
        worker = worker_class.new(item)
        worker.report_to(self)
        worker.perform
      end
    end

    def delegate_work(item, worker_class)
      gf_queue.push([item, worker_class])
    end

    def wait_for_empty
      gf_queue.wait_for_empty

      sleep(0.5)

      while gf_queue.status[gf_queue_name][:busy] != 0
        sleep(0.5)
      end
    end

    def stop
      super
      wait_for_empty
    end
  end
end
