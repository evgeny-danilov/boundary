module Payments
  class Facade
    include ::Boundary::Facade

    has_use_case :do_something, Actions::DoSomething
    has_use_case :do_something_else, Actions::DoSomethingElse
  end
end
