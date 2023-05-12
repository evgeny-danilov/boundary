require 'rails_helper'

# example of testing an inner classes, hidden by the Boundary gem
module Payments
  RSpec.describe Actions::DoSomething do
    it 'preforms an inner action' do
      expect(described_class.call).to eq('do something')
    end
  end
end
