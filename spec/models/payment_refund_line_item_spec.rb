require 'rails_helper'

RSpec.describe PaymentRefundLineItem, type: :model do

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to(:sadhak_profile)}
    it { should belong_to(:event_registration)}
    it { should belong_to(:event)}
    it { should belong_to(:event_seating_category_association)}
    it { should belong_to(:payment_refund)}
    it { should belong_to(:event_order_line_item)}
    it { should have_one(:registered_sadhak_profile).through(:event_registration).source(:sadhak_profile)}
    it { should have_one(:line_item_sadhak_profile).through(:event_order_line_item).source(:sadhak_profile)}
    it { should have_one(:seating_category).through(:event_seating_category_association)}
  end

  describe "validations" do
    it { should validate_presence_of(:event_registration_id) }
    it { should validate_presence_of(:payment_refund_id) }
  end

  describe 'delegate methods' do
    it { should delegate_method(:price).to(:event_seating_category_association).with_prefix('category').allow_nil }
    it { should delegate_method(:category_name).to(:event_seating_category_association).allow_nil }
    it { should delegate_method(:syid).to(:sadhak_profile).allow_nil }
    it { should delegate_method(:full_name).to(:sadhak_profile).allow_nil }
  end

  it do
    should define_enum_for(:status).with_values({requested: 0, done: 1, request_cancelled: 2})
    should define_enum_for(:old_item_status).with_values({cancelled: 0, transferred: 1, updated: 2, success: 3, cancelled_refunded: 4, cancelled_refund_pending: 5, upgraded: 6, downgraded: 7, name_changed: 8, shivir_changed: 9, downgrade_requested: 10, shivir_change_requested: 11, name_change_requested: 12, upgrade_requested: 13, expired: 14, renewed: 15})
  end

  describe 'aasm states' do
    event_order = FactoryBot.build_stubbed(:payment_refund_line_item)
    it { should have_state(:requested) }
    it "should transform from requested to done" do
      expect(event_order).to transition_from(:requested).to(:done).on_event(:do)
    end
  end
end
