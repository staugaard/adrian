module Adrian
  class QueueItem
    attr_reader :value, :created_at

    def initialize(value, created_at = Time.now)
      @value      = value
      @created_at = created_at
    end
  end
end
