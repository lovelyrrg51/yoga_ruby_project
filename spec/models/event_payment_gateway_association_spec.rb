require 'rails_helper'

RSpec.describe EventPaymentGatewayAssociation, type: :model do
  describe "associations" do
    it { should belong_to(:event).inverse_of(:event_payment_gateway_associations)}
    it { should belong_to(:payment_gateway)}
  end

  #scope
  describe 'Return Event Id' do
    event = FactoryBot.build_stubbed(:event)
    subject = FactoryBot.build_stubbed(:event_payment_gateway_association, event: event)
    it "should match event id" do
      expect(subject.event_id).to be(event.id)
    end
    it "should not match event id" do
      event_id = 2
      expect(subject.event_id).to_not be(event_id)
    end
  end
end
