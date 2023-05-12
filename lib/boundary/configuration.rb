# frozen_string_literal: true

class Boundary

  # TODO: rename to Configurator
  class Configuration

    extend ::Dry::Configurable

    # STRATEGIES = [ByTracePoints, ByPrivateConstants]
    # setting :strategy, default: :by_trace_points, constructor: proc { |value| value # TODO }

    setting :defined_namespaces, default: Set.new, constructor: proc { |values| Set.new(values.map(&:freeze)) }
    setting :const_get_receive_only_public_constants, default: true
    setting :allowed_class_names_for_facade, default: ['Facade']
    setting :callable_dsl_methods, default: [:has_use_case]
    setting :classable_dsl_methods, default: [:has_contract] # TODO: implement it
    setting :forbid_monkey_patching, default: true # TODO: implement it, by freezing constants

    # setting :raise_errors_environments # TODO: implement it, if needed
    # setting :prevent_overwritting, default: true # TODO: prevent adding new constants, for example, if it possible
    # setting :prevent_facade_self_methods, default: true # TODO: implement, if needed
    # setting :autoload_inner_classes # TODO: implement these feature, if you're not using Zeitwerk

  end
  private_constant :Configuration

end
