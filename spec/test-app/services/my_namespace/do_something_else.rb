# frozen_string_literal: true

module MyNamespace
  class DoSomethingElse

    include Boundary::Mixins::Callable

    def initialize(str)
      @str = str
    end

    def call
      "another #{str}"
    end

    private

    attr_reader :str

  end
end
