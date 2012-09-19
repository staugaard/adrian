module Adrian
  class Requeuer
    def initialize
      @rules = []
    end

    def add_rule(queue_name, *exceptions)
      exceptions.each do |exception_class|
        @rules << Rule.new(queue_name, exception_class)
      end
    end

    def route(exception)
      if rule = @rules.find { |r| r.match(exception) }
        rule.queue_name
      else
        nil
      end
    end

    class Rule
      attr_reader :queue_name

      def initialize(queue_name, exception_class)
        @queue_name      = queue_name
        @exception_class = exception_class
      end

      def match(exception)
        return @exception_class.nil? if exception.nil?

        return false if @exception_class.nil?

        exception.is_a?(@exception_class)
      end
    end
  end
end
