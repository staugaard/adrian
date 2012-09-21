module Adrian
  class FailureHandler
    def initialize
      @rules = []
    end

    def add_rule(*exceptions, &block)
      exceptions.each do |exception_class|
        @rules << Rule.new(exception_class, block)
      end
    end

    def handle(exception)
      if rule = @rules.find { |r| r.match(exception) }
        rule.block
      end
    end

    class Rule
      attr_reader :block

      def initialize(exception_class, block)
        @exception_class = exception_class
        @block           = block
      end

      def match(exception)
        return @exception_class.nil? if exception.nil?

        return false if @exception_class.nil?

        exception.is_a?(@exception_class)
      end
    end
  end
end
