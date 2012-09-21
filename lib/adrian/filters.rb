module Filters

  def filters
    @filters ||= []
  end

  def filter?(item)
    filters.all? { |filter| filter.allow?(item) }
  end

  class Filter

    def initialize(options = {})
      @options = options
    end

  end

  class Delay < Filter

    def allow?(item)
      item.updated_at > (Time.new - @duration)
    end

    def duration
      @options[:duration] || 15.minutes
    end

  end

  class FileLock < Filter

    def allow?(item)
      !locked?(item) || item.updated_at < (Time.new - @duration)
    end

    def locked?(item)
      @options[:reservation_path] == File.dirname(item.path)
    end

    def duration
      @options[:duration] || 1.hour
    end

  end

end
