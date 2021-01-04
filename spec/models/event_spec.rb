require 'rails_helper'

RSpec.describe Event, type: :model do

  describe "associations" do
    context 'for belongs to' do
      it { should belong_to(:creator_user).optional.class_name('User').with_foreign_key('creator_user_id') }
      it { should belong_to(:venue_type).optional }
      it { should belong_to(:cannonical_event).optional }
      it { should belong_to(:event_type).optional }
      it { should belong_to(:master_event).class_name('Event').optional }
      it { should belong_to(:sy_event_company).optional }
      it { should belong_to(:event_cancellation_plan).optional }
      it { should belong_to(:discount_plan).optional }
      it { should belong_to(:sy_event_company).optional }
    end

    context 'for has one' do
      it { should have_one(:pandal_detail) }
      it { should have_one(:bhandara_detail) }
      # it { should have_one(:attachment) }
      it { should have_one(:address).dependent(:destroy).inverse_of(:addressable) }
      it { should have_one(:reference_event).class_name('Event').with_foreign_key('reference_event_id') }
      # it { should have_one(:handy_attachment) }
    end

    context 'for has many' do
      it { should have_many(:event_references)}
      it { should have_many(:event_sponsors)}
      it { should have_many(:event_orders)}
      it { should have_many(:event_registrations)}
      # it { should have_many(:valid_event_registrations)}
      it { should have_many(:registered_sadhak_profiles).through(:valid_event_registrations).source(:sadhak_profile)}
      it { should have_many(:vaild_registered_sadhak_profiles).through(:valid_event_registrations).source(:sadhak_profile)}
      it { should have_many(:sadhak_profiles).through(:event_registrations)}
      it { should have_many(:event_seating_category_associations).inverse_of(:event)}
      it { should have_many(:seating_categories).through(:event_seating_category_associations)}
      it { should have_many(:event_awarenesses)}
      it { should have_many(:event_tax_type_associations).inverse_of(:event)}
      it { should have_many(:tax_types).through(:event_tax_type_associations)}
      it { should have_many(:event_cost_estimations)}
      # it { should have_many(:attachments)}
      it { should have_many(:event_registration_center_associations).dependent(:destroy)}
      it { should have_many(:registration_centers).through(:event_registration_center_associations)}
      it { should have_many(:event_team_details).dependent(:destroy)}
      it { should have_many(:event_payment_gateway_associations).inverse_of(:event)}
      it { should have_many(:payment_gateways).through(:event_payment_gateway_associations)}
      it { should have_many(:payment_gateway_types).through(:payment_gateways)}
      it { should have_many(:ds_shops)}
      it { should have_many(:event_digital_asset_associations).inverse_of(:event)}
      it { should have_many(:digital_assets).through(:event_digital_asset_associations)}
      # it { should have_many(:handy_attachments)}
      it { should have_many(:prerequisite_events).class_name('Event').with_foreign_key('master_event_id')}
      it { should have_many(:event_prerequisites_event_types).dependent(:destroy).inverse_of(:event)}
      it { should have_many(:event_types).through(:event_prerequisites_event_types)}
      it { should have_many(:sy_club_event_associations)}
      it { should have_many(:sy_clubs).through(:sy_club_event_associations)}
      it { should have_many(:activity_event_type_pricing_associations).dependent(:destroy)}
      it { should have_many(:event_type_pricings).through(:activity_event_type_pricing_associations)}
      it { should have_many(:event_discount_plan_associations)}
      it { should have_many(:discount_plans).through(:event_discount_plan_associations)}
      # it { should have_many(:requested_payment_refunds).class_name('PaymentRefund').with_foreign_key('event_id')}
      it { should have_many(:payment_refunds).dependent(:destroy)}
      it { should have_many(:event_cancellation_plan_items).through(:event_cancellation_plan)}
      it { should have_many(:event_order_line_items).through(:event_orders)}
    end
  end

  it do
    should define_enum_for(:payment_category).with_values({paid: 1, free: 0})
    should define_enum_for(:entity_type).with_values({product: 1})
    should define_enum_for(:status).with_values({proposed: 0, approved: 1, cancelled: 2, test_registration: 3, ready: 4, suspended: 5, closed: 6})
  end

  #AASM
  describe 'aasm states' do
    event = FactoryBot.build(:event)
    it { should have_state(:proposed).on(:aasm_event_status) }
    it "should transform from proposed to proposed" do
      expect(event).to transition_from(:proposed).to(:proposed).on_event(:proposed).on(:aasm_event_status)
    end
    it "should transform from approved to proposed" do
      expect(event).to transition_from(:approved).to(:proposed).on_event(:proposed).on(:aasm_event_status)
    end
    it "should transform from test_registration to pending" do
      expect(event).to transition_from(:test_registration).to(:proposed).on_event(:proposed).on(:aasm_event_status)
    end
    it "should transform from ready to proposed" do
      expect(event).to transition_from(:ready).to(:proposed).on_event(:proposed).on(:aasm_event_status)
    end
    it "should transform from suspended to proposed" do
      expect(event).to transition_from(:suspended).to(:proposed).on_event(:proposed).on(:aasm_event_status)
    end
    it "should transform from cancelled to proposed" do
      expect(event).to transition_from(:cancelled).to(:proposed).on_event(:proposed).on(:aasm_event_status)
    end
    it "should transform from closed to proposed" do
      expect(event).to transition_from(:closed).to(:proposed).on_event(:proposed).on(:aasm_event_status)
    end
    it "should transform from proposed to approved" do
      expect(event).to transition_from(:proposed).to(:approved).on_event(:approved).on(:aasm_event_status)
    end
    it "should transform from proposed to cancelled" do
      expect(event).to transition_from(:proposed).to(:cancelled).on_event(:cancelled).on(:aasm_event_status)
    end
    it "should transform from approved to cancelled" do
      expect(event).to transition_from(:approved).to(:cancelled).on_event(:cancelled).on(:aasm_event_status)
    end
    it "should transform from ready to cancelled" do
      expect(event).to transition_from(:ready).to(:cancelled).on_event(:cancelled).on(:aasm_event_status)
    end
    it "should transform from test_registration to cancelled" do
      expect(event).to transition_from(:test_registration).to(:cancelled).on_event(:cancelled).on(:aasm_event_status)
    end
    it "should transform from suspended to cancelled" do
      expect(event).to transition_from(:suspended).to(:cancelled).on_event(:cancelled).on(:aasm_event_status)
    end
    it "should transform from closed to cancelled" do
      expect(event).to transition_from(:closed).to(:cancelled).on_event(:cancelled).on(:aasm_event_status)
    end
    it "should transform from proposed to test_registration" do
      expect(event).to transition_from(:proposed).to(:test_registration).on_event(:test_registration).on(:aasm_event_status)
    end
    it "should transform from approved to test_registration" do
      expect(event).to transition_from(:approved).to(:test_registration).on_event(:test_registration).on(:aasm_event_status)
    end
    it "should transform from proposed to ready" do
      expect(event).to transition_from(:proposed).to(:ready).on_event(:ready).on(:aasm_event_status)
    end
    it "should transform from approved to ready" do
      expect(event).to transition_from(:approved).to(:ready).on_event(:ready).on(:aasm_event_status)
    end
    it "should transform from test_registration to ready" do
      expect(event).to transition_from(:test_registration).to(:ready).on_event(:ready).on(:aasm_event_status)
    end
    it "should transform from proposed to suspended" do
      expect(event).to transition_from(:proposed).to(:suspended).on_event(:suspended).on(:aasm_event_status)
    end
    it "should transform from approved to suspended" do
      expect(event).to transition_from(:approved).to(:suspended).on_event(:suspended).on(:aasm_event_status)
    end
    it "should transform from test_registration to suspended" do
      expect(event).to transition_from(:test_registration).to(:suspended).on_event(:suspended).on(:aasm_event_status)
    end
    it "should transform from ready to suspended" do
      expect(event).to transition_from(:ready).to(:suspended).on_event(:suspended).on(:aasm_event_status)
    end
    it "should transform from proposed to closed" do
      expect(event).to transition_from(:proposed).to(:closed).on_event(:closed).on(:aasm_event_status)
    end
    it "should transform from approved to closed" do
      expect(event).to transition_from(:approved).to(:closed).on_event(:closed).on(:aasm_event_status)
    end
    it "should transform from test_registration to closed" do
      expect(event).to transition_from(:test_registration).to(:closed).on_event(:closed).on(:aasm_event_status)
    end
    it "should transform from ready to closed" do
      expect(event).to transition_from(:ready).to(:closed).on_event(:closed).on(:aasm_event_status)
    end
    it "should transform from suspended to closed" do
      expect(event).to transition_from(:suspended).to(:closed).on_event(:closed).on(:aasm_event_status)
    end
  end

  describe 'delegate methods' do
    it { should delegate_method(:full_address).to(:address).allow_nil }
    it { should delegate_method(:name).to(:event_type).allow_nil.with_prefix }
    it { should delegate_method(:street_address).to(:address).allow_nil }
    it { should delegate_method(:country_name).to(:address).allow_nil }
    it { should delegate_method(:country_id).to(:address).allow_nil }
    it { should delegate_method(:state_name).to(:address).allow_nil }
    it { should delegate_method(:city_name).to(:address).allow_nil }
    it { should delegate_method(:country_currency_code).to(:address).allow_nil }
    it { should delegate_method(:country_telephone_prefix).to(:address).allow_nil }
    it { should delegate_method(:country_ISO2).to(:address).allow_nil }
    it { should delegate_method(:postal_code).to(:address).allow_nil }
  end

  it do
    should accept_nested_attributes_for(:address).allow_destroy(true)
    should accept_nested_attributes_for(:event_seating_category_associations).allow_destroy(true)
    should accept_nested_attributes_for(:prerequisite_events)
    should accept_nested_attributes_for(:event_types)
  end
  # it { expect { FactoryBot.attributes_for(:attachment) }.to change(Attachment, :count).by(1) }
  # it { expect { FactoryBot.attributes_for(:attachment, :name => '') }.to_not change(Attachment, :count) }

end
