require 'rails_helper'

RSpec.describe PurchasedDigitalAsset, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:digital_asset) }
  end
end
