require 'rails_helper'

RSpec.describe PaymentMode, type: :model do

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should have_many(:payment_gateway_mode_associations).dependent(:destroy)}
    it { should have_many(:payment_gateways).through(:payment_gateway_mode_associations)}
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:group_name) }
    it { should validate_presence_of(:shortcode) }
    it { should validate_uniqueness_of(:name).ignoring_case_sensitivity }
  end

  it do
    should define_enum_for(:group_name).with([:net_banking, :credit_card, :debit_card, :mobile_payment, :cash_card, :emi, :ivrs, :wallet])
  end

end
