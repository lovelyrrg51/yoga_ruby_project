require 'rails_helper'

RSpec.describe EventRegistration, type: :model do

  #associations
  describe "associations" do
    context 'for belongs to' do
      it { should belong_to(:event) }
      it { should belong_to(:user).optional }
      it { should belong_to(:sadhak_profile) }
      it { should belong_to(:event_order_line_item).dependent(:destroy).optional }
      it { should belong_to(:event_seating_category_association).optional}
      it { should belong_to(:event_order).optional}
      it { should belong_to(:sy_event_company).optional}
    end

    context 'for has one' do
      it { should have_one(:seating_category).through(:event_seating_category_association) }
      it { should have_one(:parent_registration).class_name('EventRegistration').with_foreign_key('id').with_primary_key('renewed_from') }
      it { should have_one(:child_registration).class_name('EventRegistration').with_foreign_key('renewed_from')}
      it { should have_one(:sy_club_member) }
      it { should have_one(:receipt_voucher) }
      it { should have_one(:receipt_voucher_attachment) }
      it { should have_one(:invoice_voucher) }
      it { should have_one(:invoice_voucher_attachment) }
      it { should have_one(:refund_voucher) }
      it { should have_one(:refund_voucher_attachment) }
      it { should have_one(:payment_refund_line_item) }

    end

    context 'for has many' do
      it { should have_many(:vouchers).dependent(:destroy) }
    end
  end

  describe 'delegate methods' do
    it { should delegate_method(:rgba).to(:seating_category).allow_nil }
    it { should delegate_method(:reg_ref_number).to(:event_order).allow_nil }
    it { should delegate_method(:event_start_date).to(:event).allow_nil }
    it { should delegate_method(:event_end_date).to(:event).allow_nil }
    it { should delegate_method(:event_name).to(:event).allow_nil }
    it { should delegate_method(:event_location).to(:event).allow_nil }
    it { should delegate_method(:price).to(:event_seating_category_association).allow_nil }
  end


  it { should define_enum_for(:status).with_values({ cancelled: 0, transferred: 1, updated: 2, success: 3, cancelled_refunded: 4, cancelled_refund_pending: 5, upgraded: 6, downgraded: 7, name_changed: 8, shivir_changed: 9, downgrade_requested: 10, shivir_change_requested: 11, name_change_requested: 12, upgrade_requested: 13, expired: 14, renewed: 15 }) }

  #validations
  # describe "validations" do
  #   it { should validate_uniqueness_of(:sadhak_profile_id).scoped_to(:event_order_id) }
  # end
end