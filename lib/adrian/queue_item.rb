module Adrian
  class QueueItem
    attr_reader :value, :created_at
    attr_accessor :queue

    def initialize(value, created_at = Time.now)
      @value      = value
      @created_at = created_at
    end

    def age
      Time.now - created_at
    end
  end
end
