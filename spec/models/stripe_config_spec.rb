require 'rails_helper'

RSpec.describe StripeConfig, type: :model do

  describe "associations" do
    it { should belong_to(:payment_gateway).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:alias_name) }
    it { should validate_presence_of(:payment_gateway) }
    it { should validate_uniqueness_of(:alias_name) }
  end
end