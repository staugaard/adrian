module Adrian
  module Filters

    def filters
      @filters ||= []
    end

    def filter?(item)
      !filters.all? { |filter| filter.allow?(item) }
    end

    class Delay

      def initialize(options = {})
        @options = options
      end

      def allow?(item)
        item.updated_at <= (Time.new - duration)
      end

      # Default is 15 minutes
      def duration
        @options[:duration] || 900
      end

    end

    class FileLock

      def initialize(options = {})
        @options = options
      end

      def allow?(item)
        !locked?(item) || item.updated_at <= (Time.new - @duration)
      end

      def locked?(item)
        @options[:reservation_path] == File.dirname(item.path)
      end

      # Default is an hour
      def duration
        @options[:duration] || 3_600
      end

    end

  end
end
