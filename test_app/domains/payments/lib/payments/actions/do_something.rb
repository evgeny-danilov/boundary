module Payments
  module Actions
    class DoSomething
      include ::Boundary::Mixins::Callable

      def call
        'do something'
      end
    end
  end
end
