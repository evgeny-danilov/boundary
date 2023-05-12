require 'rails_helper'

RSpec.describe Payments do
  it 'has public interface' do
    expect(Payments::Facade.do_something).to eq('do something')
    expect(Payments::Facade.do_something_else).to eq('do something else')
  end

  it 'has hidden implementation' do
    expect { Payments::VERSION }.to raise_error(NameError, 'private constant Payments::VERSION referenced')
    expect { Payments::Actions }.to raise_error(NameError, 'private constant Payments::Actions referenced')
  end
end
