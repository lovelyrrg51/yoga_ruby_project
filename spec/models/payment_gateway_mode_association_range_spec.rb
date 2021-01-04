require 'rails_helper'

RSpec.describe PaymentGatewayModeAssociationRange, type: :model do

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to(:payment_gateway_mode_association)}
    # it { should have_one(:payment_gateway)} # payment_gateway_mode_association_range_id is not present
    # it { should have_one(:payment_mode)} # payment_gateway_mode_association_range_id is not present
  end

  describe "validations" do
    it { should validate_presence_of(:min_value) }
    it { should validate_presence_of(:percent) }
    it { should validate_presence_of(:payment_gateway_mode_association) }
    it { should validate_numericality_of(:percent).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100) }
    it { should validate_numericality_of(:min_value).is_greater_than_or_equal_to(0) }
  end
end
