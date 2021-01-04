require 'rails_helper'

RSpec.describe Order, type: :model do
  describe "associations" do
    it { should have_many(:line_items)}
    it { should have_many(:digital_assets).through(:line_items)}
    it { should belong_to(:user)}
  end

  it do
    should define_enum_for(:status).with_values({cart: 0, payment_success: 1, delivered: 2, closed: 3})
  end

   #AASM
  describe 'aasm states' do
    order = FactoryBot.build(:order)
    it { should have_state(:cart) }
    it "should transform from cart to payment_success" do
      expect(order).to transition_from(:cart).to(:payment_success).on_event(:successful_payment)
    end
    it "should transform from payment_success to delivered" do
      expect(order).to transition_from(:payment_success).to(:delivered).on_event(:deliver_order)
    end
    it "should transform from cart to closed" do
      expect(order).to transition_from(:cart).to(:closed).on_event(:abort_order)
    end
  end
end
