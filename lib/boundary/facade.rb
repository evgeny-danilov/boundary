# frozen_string_literal: true

class Boundary

  module Facade
    def self.included(facade)
      Privatizator.new(facade: facade).call

      Configuration.config.callable_dsl_methods.each do |method_name|
        facade.define_singleton_method(method_name) do |name, callable_class|
          define_singleton_method(name, &callable_class.method(:call))
        end
        facade.private_class_method(method_name)
      end
    end
  end

end
