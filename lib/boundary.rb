# frozen_string_literal: true

require 'dry-configurable'

class Boundary

  private_class_method :new

  def self.initialize(&block)
    Configuration.configure do |config|
      block.call(config) if block_given?

      config.finalize!(freeze_values: true)
      # TODO: add in documentation: we make it immutable, as this config is a global state.
      #   So, immutability here is to reduce possible side effect due to overwriting the configuration.
    end
  end

end
