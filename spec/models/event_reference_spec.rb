require 'rails_helper'

RSpec.describe EventReference, type: :model do
  describe "associations" do
    it { should belong_to(:sadhak_profile)}
    it { should belong_to(:event)}
  end

  #scope
  describe 'Return Event Id' do
    event = FactoryBot.build_stubbed(:event)
    subject = FactoryBot.build_stubbed(:event_reference, event: event)
    it "should match event id" do
      expect(subject.event_id).to be(event.id)
    end
    it "should not match event id" do
      event_id = 2
      expect(subject.event_id).to_not be(event_id)
    end
  end
end
