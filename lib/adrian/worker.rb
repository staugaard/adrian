module Adrian
  class Worker
    attr_reader :item

    def initialize(item)
      @item = item
    end

    def report_to(boss)
      @boss = boss
    end

    def perform
      exception = nil

      begin
        work
      rescue Exception => e
        exception = e
      end

      @boss.work_done(self, item, exception)
    end

    def work
      raise "You need to implement #{self.class.name}#work"
    end
  end
end
