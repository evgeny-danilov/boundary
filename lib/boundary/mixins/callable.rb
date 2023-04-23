# frozen_string_literal: true

class Boundary

  module Mixins
    module Callable
      def self.included(klass)
        klass.extend(ClassMethods)
      end

      def call(*)
        raise NotImplementedError, "#{self.class} does not implement a #call method"
      end

      module ClassMethods
        def call(...)
          new(...).call
        end
      end
    end
  end

end
