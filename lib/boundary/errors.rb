# frozen_string_literal: true

class Boundary

  module Errors
    WrongNamespaceError = Class.new(::StandardError)
    WrongFacadeClassNameError = Class.new(::StandardError)
  end

end
