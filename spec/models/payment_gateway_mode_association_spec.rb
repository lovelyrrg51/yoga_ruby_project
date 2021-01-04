require 'rails_helper'

RSpec.describe PaymentGatewayModeAssociation, type: :model do

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to(:payment_gateway)}
    it { should belong_to(:payment_mode)}
    it { should have_many(:payment_gateway_mode_association_ranges).dependent(:destroy)}
    it { should have_many(:payment_gateway_mode_association_tax_types).dependent(:destroy)}
  end

  describe "validations" do
    it { should validate_presence_of(:payment_gateway) }
    it { should validate_presence_of(:payment_mode) }
    it { should validate_presence_of(:percent_type) }
    # it { should validate_uniqueness_of(:payment_mode).scoped_to(:payment_gateway) }
    it { should validate_presence_of(:percent) }
    it { should validate_numericality_of(:percent).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100) }
    # it { should validate_length_of(:payment_gateway_mode_association_ranges).is_at_least(1).with_message("Minimum 1 payment gateway range required.") }
  end

  it do
    should define_enum_for(:percent_type).with([:fixed, :range])
  end

  it { should delegate_method(:shortcode).to(:payment_mode) }

  describe 'aasm states' do
    it { should have_state(:fixed) }
  end

end
