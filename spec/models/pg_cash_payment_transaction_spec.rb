require 'rails_helper'

RSpec.describe PgCashPaymentTransaction, type: :model do

  it { should belong_to(:event_order) }
  it { should belong_to(:sy_club).optional }

  it { should validate_presence_of(:payment_date) }
  it { should validate_presence_of(:amount) }

  it do
    should define_enum_for(:status).with_values({pending: 0, approved: 1})
  end

  describe 'aasm states' do
    event_order = FactoryBot.build_stubbed(:pg_cash_payment_transaction)
    it { should have_state(:pending) }
    it "should transform from pending to approved" do
      expect(event_order).to transition_from(:pending).to(:approved).on_event(:approve_details)
    end
  end
end
