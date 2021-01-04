require 'rails_helper'

RSpec.describe StripeSubscription, type: :model do

  describe "associations" do
    it { should belong_to(:event_order).optional }
    it { should belong_to(:sy_club).optional }
  end

  it { should define_enum_for(:status).with_values({pending: 0, success: 1}) }

  #AASM
  describe 'aasm states' do
    stripe_subscription = FactoryBot.build(:stripe_subscription)
    it { should have_state(:pending) }
    it "should transform from pending to success" do
      expect(stripe_subscription).to transition_from(:pending).to(:success).on_event(:approve_details)
    end
  end
end