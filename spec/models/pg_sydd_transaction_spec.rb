require 'rails_helper'

RSpec.describe PgSyddTransaction, type: :model do

  describe "associations" do
    it { should belong_to(:pg_sydd_merchant).optional }
    it { should belong_to(:event_order).optional }
    it { should belong_to(:sy_club).optional }
  end

  describe "validations" do
    it { should validate_presence_of(:dd_number) }
    it { should validate_presence_of(:dd_date) }
    it { should validate_presence_of(:bank_name) }
    it { should validate_presence_of(:amount) }
  end

  it do
    should define_enum_for(:status).with_values({pending: 0, approved: 1})
  end

  describe 'aasm states' do
    pg_sydd_transaction = FactoryBot.build(:pg_sydd_transaction)
    it { should have_state(:pending) }
    it "should transform from pending to approved" do
      expect(pg_sydd_transaction).to transition_from(:pending).to(:approved).on_event(:approve_details)
    end
  end

end
