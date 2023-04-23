# frozen_string_literal: true

module MyNamespace
  class Facade

    include Boundary::Facade

    has_use_case :do_something, DoSomething
    has_use_case :do_something_else, DoSomethingElse

  end
end
