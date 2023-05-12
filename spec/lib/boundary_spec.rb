# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Boundary do
  it 'has a version number' do
    expect(Boundary::VERSION).not_to be_nil
  end

  context 'when applied to a namespace' do
    let(:dummy_namespace) do
      self.class.module_eval <<~RUBY, __FILE__, __LINE__ + 1
        module DummyNamespace
          class Facade; end
    
          class DummyAction
            include Boundary::Mixins::Callable
  
            def call
              'dummy action result'
            end
          end
  
          class Facade
            include Boundary::Facade
  
            has_use_case :dummy_action, DummyAction
          end
        end
      RUBY

      self.class::DummyNamespace
    end

    before do
      Boundary.initialize do |config|
        config.defined_namespaces = [dummy_namespace::Facade.to_s]
      end
    end

    it 'provides public interface' do
      expect(dummy_namespace::Facade.dummy_action).to eq('dummy action result')
    end

    it 'hides inner constants' do
      expect(dummy_namespace.constants).to contain_exactly(:Facade)
    end
  end
end
