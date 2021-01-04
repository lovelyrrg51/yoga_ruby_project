require 'rails_helper'

RSpec.describe PaymentRefund, type: :model do

  describe "associations" do
    it { should belong_to(:event) }
    it { should belong_to(:event_order) }
    it { should belong_to(:requester_user).class_name('User').with_foreign_key('requester_id').optional }
    it { should belong_to(:responder_user).class_name('User').with_foreign_key('responder_id').optional }
    it { should belong_to(:event_cancellation_plan).optional }
    it { should belong_to(:shifted_event_order).class_name('EventOrder').with_foreign_key('shifted_event_order_id').optional }
    it { should have_many(:payment_refund_line_items).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:event_id) }
    it { should validate_presence_of(:event_order_id) }
  end

  it do
    should define_enum_for(:status).with_values({requested: 0, refunded: 1, request_cancelled: 2, done: 3})
    should define_enum_for(:action).with_values({cancellation: 1, downgrade: 2, transfer: 3, transfer_downgrade: 4, update_record: 5, upgrade: 6})
    should define_enum_for(:item_status).with_values({cancelled: 0, transferred: 1, updated: 2, success: 3, cancelled_refunded: 4, cancelled_refund_pending: 5, upgraded: 6, downgraded: 7, name_changed: 8, shivir_changed: 9, downgrade_requested: 10, shivir_change_requested: 11, name_change_requested: 12, upgrade_requested: 13})
  end

  it { should serialize(:request_object) }

  describe 'aasm states' do
    event_order = FactoryBot.build_stubbed(:payment_refund)
    it { should have_state(:requested) }
    it "should transform from requested to refunded" do
      expect(event_order).to transition_from(:requested).to(:refunded).on_event(:refund)
    end
  end

  describe 'default scope' do
    is_deleted = false
    it "should return collection whose is_deleated is false" do
      expect(is_deleted).to eq(subject.is_deleted)
    end
  end

end
