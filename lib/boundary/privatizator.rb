# frozen_string_literal: true

class Boundary

  class Privatizator

    def initialize(facade:)
      @facade = facade
      @facade_name = demodulize_class_name(facade)
      @namespace = facade_namespace(facade)
    end

    def call
      raise Errors::WrongFacadeClassNameError if invalid_facade_name?
      raise Errors::WrongNamespaceError if config.frozen? && !config.defined_namespaces.include?(facade)

      privatize_initializer
      privatize_inner_classes
      extend_const_get_method if config.const_get_receive_only_public_constants == true
    end

    private

    attr_reader :facade, :facade_name, :namespace

    def privatize_initializer
      facade.private_class_method :new
    end

    def privatize_inner_classes
      namespace.constants
               .delete_if { _1.to_s.casecmp?(facade_name) }
               .each { namespace.private_constant(_1) }
    end

    def facade_namespace(klass)
      parent_class_string = klass.to_s.split('::')[0..-2].join('::')
      Object.const_get(parent_class_string)
    end

    def demodulize_class_name(klass)
      klass.to_s.split('::').last
    end

    def invalid_facade_name?
      !config.allowed_class_names_for_facade.include?(facade_name)
    end

    def extend_const_get_method
      namespace.define_singleton_method(:const_get) do |const, inherit = nil|
        next super(const, inherit) if constants.include?(const.to_sym)

        raise(NameError, "private constant #{self}::#{const} referenced")
      end
    end

    def config
      Configuration.config
    end

  end
  private_constant :Privatizator

end
