# frozen_string_literal: true

module MyNamespace
  class DoSomething

    include Boundary::Mixins::Callable

    def initialize(str)
      @str = str
    end

    def call
      [str, Subactions::Do.new.call].join(' & ')
    end

    private

    attr_reader :str

  end
end
