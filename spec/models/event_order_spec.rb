require 'rails_helper'

RSpec.describe EventOrder, type: :model do

  describe "associations" do
    context 'for belongs to' do
      it { should belong_to(:user).optional }
      it { should belong_to(:event) }
      it { should belong_to(:registration_center_user).optional }
      it { should belong_to(:sy_club).optional }
    end

    context 'for has one' do
      it { should have_one(:registration_center).through(:registration_center_user) }
      it { should have_one(:attachment) }
    end

    context 'for has many' do
      it { should have_many(:event_order_line_items).dependent(:destroy) }
      it { should have_many(:sadhak_profiles).through(:event_order_line_items) }
      it { should have_many(:event_registrations).dependent(:destroy) }
      it { should have_many(:pg_cash_payment_transactions).dependent(:destroy) }
      it { should have_many(:pg_sydd_transactions).dependent(:destroy) }
      it { should have_many(:order_payment_informations).dependent(:destroy) }
      it { should have_many(:stripe_subscriptions).dependent(:destroy) }
      it { should have_many(:pg_sy_razorpay_payments).dependent(:destroy) }
      it { should have_many(:pg_sy_braintree_payments).dependent(:destroy) }
      it { should have_many(:pg_sy_paypal_payments).dependent(:destroy) }
      it { should have_many(:pg_sy_payfast_payments).dependent(:destroy) }
      it { should have_many(:transaction_logs) }
      it { should have_many(:event_seating_category_associations).through(:valid_line_items).source(:event_seating_category_association) }
      it { should have_many(:valid_line_items).conditions(event_order_line_items: {status: EventOrderLineItem.valid_line_item_statuses}).class_name('EventOrderLineItem') }
      it { should have_many(:registered_sadhak_profiles).conditions(event_registrations: {status: EventRegistration.valid_registration_statuses}).through(:event_registrations).source(:sadhak_profile) }
      it { should have_many(:valid_event_registrations).conditions(event_registrations: {status: EventRegistration.valid_registration_statuses}).class_name('EventRegistration') }
    end
  end

  context 'for serialize' do
    it { should serialize(:tax_details) }
    it { should serialize(:order_tax_detail) }
    it { should serialize(:total_tax_details) }
  end

  describe "validations" do
    it { should validate_presence_of(:event_id) }
  end

  describe 'delegate methods' do
    it { should delegate_method(:event_name).to(:event).allow_nil }
    it { should delegate_method(:email).to(:user).allow_nil.with_prefix(:user) }
  end

  it { should define_enum_for(:status).with_values({pending: 0, success: 1, failure: 2, approve: 3, rejected: 4, dd_received_by_rc: 5, dd_received_by_ashram: 6, dd_received_by_india_admin: 7}) }

  describe 'default scope' do
    is_deleted = false
    it "should return collection whose is_deleated is false" do
      expect(is_deleted).to eq(subject.is_deleted)
    end
  end

  describe 'aasm states' do
    event_order = FactoryBot.build_stubbed(:event_order)
    it { should have_state(:pending) }
    it "should transform from approve to pending" do
      expect(event_order).to transition_from(:approve).to(:pending).on_event(:pending)
    end
    it "should transform from reject to pending" do
      expect(event_order).to transition_from(:rejected).to(:pending).on_event(:pending)
    end
    it "should transform from failure to pending" do
      expect(event_order).to transition_from(:failure).to(:pending).on_event(:pending)
    end
    it "should transform from pending to approve" do
      expect(event_order).to transition_from(:pending).to(:approve).on_event(:approve)
    end
    it "should transform from pending to reject" do
      expect(event_order).to transition_from(:pending).to(:rejected).on_event(:rejected)
    end
    it "should transform from pending to failure" do
      expect(event_order).to transition_from(:pending).to(:failure).on_event(:failure)
    end
    it "should transform from approve to failure" do
      expect(event_order).to transition_from(:approve).to(:failure).on_event(:failure)
    end
    it "should transform from pending to success" do
      expect(event_order).to transition_from(:pending).to(:success).on_event(:success)
    end
    it "should transform from approve to success" do
      expect(event_order).to transition_from(:approve).to(:success).on_event(:success)
    end
    it "should transform from failure to success" do
      expect(event_order).to transition_from(:failure).to(:success).on_event(:success)
    end
    it "should transform from success to success" do
      expect(event_order).to transition_from(:success).to(:success).on_event(:success)
    end
    it "should transform from pending to dd_received_by_rc" do
      expect(event_order).to transition_from(:pending).to(:dd_received_by_rc).on_event(:dd_received_by_rc)
    end
    it "should transform from pending to dd_received_by_india_admin" do
      expect(event_order).to transition_from(:pending).to(:dd_received_by_india_admin).on_event(:dd_received_by_india_admin)
    end
    it "should transform from pending to dd_received_by_ashram" do
      expect(event_order).to transition_from(:pending).to(:dd_received_by_ashram).on_event(:dd_received_by_ashram)
    end
  end
end
