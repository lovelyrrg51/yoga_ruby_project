require 'rails_helper'

RSpec.describe PaymentGateway, type: :model do
  
  describe "associations" do
    it { should belong_to(:payment_gateway_type)}
    it { should have_one(:pg_sydd_config)}
    it { should have_one(:ccavenue_config)}
    it { should have_one(:hdfc_config)}
    it { should have_one(:stripe_config)}
    it { should have_one(:pg_sy_razorpay_config)}
    it { should have_one(:pg_sy_braintree_config)}
    it { should have_one(:pg_sy_paypal_config)}
    it { should have_one(:pg_sy_payfast_config)}
    it { should have_many(:event_payment_gateway_associations).dependent(:destroy)}
    it { should have_many(:events).through(:event_payment_gateway_associations)}
    it { should have_many(:sy_club_payment_gateway_associations)}
    # it { should have_many(:sy_clubs).through(:sy_club_payment_gateway_associations)} # getting class_name nil
    it { should have_many(:payment_gateway_mode_associations).dependent(:destroy)}
    it { should have_many(:payment_modes).through(:payment_gateway_mode_associations)}
  end
end
