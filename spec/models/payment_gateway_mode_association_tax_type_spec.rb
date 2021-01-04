require 'rails_helper'

RSpec.describe PaymentGatewayModeAssociationTaxType, type: :model do

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to(:tax_type)}
    it { should belong_to(:payment_gateway_mode_association)}
  end

  describe "validations" do
    # subject {FactoryBot.build(:payment_gateway_mode_association_tax_type)}
    it { should validate_presence_of(:tax_type) }
    it { should validate_presence_of(:payment_gateway_mode_association) }
    it { should validate_presence_of(:percent) }
    # it { should validate_uniqueness_of(:tax_type).scoped_to(:payment_gateway_mode_association) }
    it { should validate_numericality_of(:percent).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100) }
  end

  it { should delegate_method(:name).to(:tax_type).with_prefix('tax_type').allow_nil }

end
