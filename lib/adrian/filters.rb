module Adrian
  module Filters

    def filters
      @filters ||= []
    end

    def filter?(item)
      !filters.all? { |filter| filter.allow?(item) }
    end

    class Delay
      FIFTEEN_MINUTES = 900

      def initialize(options = {})
        @options = options
      end

      def allow?(item)
        item.updated_at <= (Time.new - duration)
      end

      def duration
        @options[:duration] ||= FIFTEEN_MINUTES
      end

    end

    class FileLock
      ONE_HOUR = 3_600

      def initialize(options = {})
        @options       = options
        @reserved_path = @options.fetch(:reserved_path)
      end

      def allow?(item)
        !locked?(item) || lock_expired?(item)
      end

      def lock_expired?(item)
        item.updated_at <= (Time.new - duration)
      end

      def locked?(item)
        @reserved_path == File.dirname(item.path)
      end

      def duration
        @options[:duration] ||= ONE_HOUR
      end

    end

  end
end
