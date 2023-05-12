# require "payments/version"

require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.setup

require_relative 'payments/version'

# module Payments
#   # Your code goes here...
# end
