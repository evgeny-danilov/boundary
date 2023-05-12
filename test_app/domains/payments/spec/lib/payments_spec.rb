require 'spec_helper'

RSpec.describe Payments do
  it 'provides a version through the facade' do
    expect(Payments::Facade.version).to eq('0.1.0')
  end
end
