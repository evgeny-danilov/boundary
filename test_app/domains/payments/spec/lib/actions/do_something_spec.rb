require 'spec_helper'

RSpec.describe Payments::Actions::DoSomething do
  it 'executes a dummy actions' do
    expect(subject.call).to eq('do something')
  end
end
