require 'rails_helper'

RSpec.describe EventOrderLineItem, type: :model do
  #associations
  describe "associations" do
    context 'for belongs to' do
      it { should belong_to(:event_order) }
      it { should belong_to(:sadhak_profile) }
      it { should belong_to(:seating_category).optional }
      it { should belong_to(:event_seating_category_association) }
      it { should belong_to(:transferred_event_order).class_name('EventOrder').with_foreign_key('transferred_ref_number').with_primary_key('reg_ref_number').optional }
      # it { should belong_to(:eveny_type_pricing) }
    end

    context 'for has one' do
      it { should have_one(:event_registration) }
      it { should have_one(:special_event_sadhak_profile_other_info).dependent(:destroy) }
      it { should have_one(:sy_club_member).through(:event_registration) }
      it { should have_one(:event).through(:event_order).source(:event) }
      it { should have_one(:payment_refund_line_item).conditions(payment_refund_line_items: {status: PaymentRefundLineItem.statuses["requested"]}) }
    end

    context 'for has many' do
      it { should have_many(:payment_refund_line_items).dependent(:destroy) }
    end
  end

  #serialize
  context 'for serialize' do
    it { should serialize(:tax_types).as(Array) }
    it { should serialize(:tax_details) }
    it { should serialize(:total_tax_detail) }
  end

  #enum
  it { should define_enum_for(:status).with_values({cancelled: 0, transferred: 1, updated: 2, success: 3, cancelled_refunded: 4, cancelled_refund_pending: 5, upgraded: 6, downgraded: 7, name_changed: 8, shivir_changed: 9, downgrade_requested: 10, shivir_change_requested: 11, name_change_requested: 12, upgrade_requested: 13, expired: 14, renewed: 15}) }

  #delegate
  describe 'delegate methods' do
    it { should delegate_method(:syid).to(:sadhak_profile).allow_nil }
    it { should delegate_method(:full_name).to(:sadhak_profile).allow_nil }
    it { should delegate_method(:reg_ref_number).to(:event_order).allow_nil }
    it { should delegate_method(:category_name).to(:event_seating_category_association).allow_nil }
    it { should delegate_method(:price).to(:event_seating_category_association).with_prefix(:category).allow_nil }
  end

  describe 'aasm states' do
    it { should have_state(:success) }
  end

   #scope

  describe 'Return Event Order Id' do
    event_order = FactoryBot.build_stubbed(:event_order)
    subject = FactoryBot.build_stubbed(:event_order_line_item, event_order: event_order)
    it "should match event order id" do
      expect(subject.event_order_id).to be(event_order.id)
    end
    it "should not match event order id" do
      event_order_id = 2
      expect(subject.event_order_id).to_not be(event_order_id)
    end
  end

end