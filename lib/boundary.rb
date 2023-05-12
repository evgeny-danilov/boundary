# frozen_string_literal: true

require 'dry-configurable'

loader = Zeitwerk::Loader.for_gem.tap do |loader|
  loader.enable_reloading
  loader.setup
end

class Boundary

  private_class_method :new

  def self.initialize(&block) # TODO: check if we can delegate the method directly to Configuration
    Configuration.configure(&block)

    Configuration.config.defined_namespaces.each do |namespace|
      facade = Object.const_get(namespace.to_s)
      Privatizator.new(facade: facade).call
    end

  end

end
