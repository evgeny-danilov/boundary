# frozen_string_literal: true

# Part of the framework (in-build, no need to add it manually)
global_loader = Zeitwerk::Loader.new.tap do |loader|
  loader.push_dir("#{__dir__}/../lib/")
  loader.push_dir("#{__dir__}/test-app/services/")
  loader.enable_reloading
  loader.setup
end

# Part of the app's initialization
global_loader.on_setup do
  Boundary.initialize do |config|
    config.defined_namespaces = [MyNamespace::Facade]
  end
end

RSpec.describe Boundary do
  it 'has a version number' do
    expect(Boundary::VERSION).not_to be_nil
  end

  context 'when namespace is bounded by the Facade' do
    let(:target_namespace) { MyNamespace }

    it 'exposes public interface' do
      expect(target_namespace::Facade.do_something('action')).to eq('action & subaction')
      expect(target_namespace::Facade.do_something_else('action')).to eq('another action')
    end

    it 'raises en error when accessing to an inner class' do
      expect { target_namespace::DoSomething }
        .to raise_error(NameError, "private constant #{target_namespace}::DoSomething referenced")

      expect { target_namespace.const_get(:DoSomething) }
        .to raise_error(NameError, "private constant #{target_namespace}::DoSomething referenced")
    end

    context 'when reloading the code' do
      before { global_loader.reload }

      it 'exposes public interface' do
        expect(target_namespace::Facade.do_something('action')).to eq('action & subaction')
        expect(target_namespace::Facade.do_something_else('action')).to eq('another action')
      end

      it 'raises en error when accessing to an inner class' do
        expect { target_namespace::DoSomething }
          .to raise_error(NameError, "private constant #{target_namespace}::DoSomething referenced")

        expect { target_namespace.const_get(:DoSomething) }
          .to raise_error(NameError, "private constant #{target_namespace}::DoSomething referenced")
      end
    end

    context 'when trying to modify public Facade after initialization' do
      it 'raises an error' do
        expect do
          target_namespace::Facade.class_eval { def self.some_method; end }
        end.to raise_error(FrozenError, "can't modify frozen Class: #{target_namespace}::Facade")
      end
    end

    context 'when trying to change already initialized configuration' do
      it 'does not raise an error' do
        expect { described_class.initialize { _1.defined_namespaces = nil } }
          .to raise_error(Dry::Configurable::FrozenConfigError, 'Cannot modify frozen config')
      end
    end

    context 'when boundary facade applies for a namespace not included in the white list' do
      it 'raise an error' do
        expect { AnotherNamespace::Facade }.to raise_error(Boundary::Errors::WrongNamespaceError)
      end
    end
  end
end
