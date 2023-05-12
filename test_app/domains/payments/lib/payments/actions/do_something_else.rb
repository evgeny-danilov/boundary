module Payments
  module Actions
    class DoSomethingElse
      include ::Boundary::Mixins::Callable

      def call
        'do something else'
      end
    end
  end
end
