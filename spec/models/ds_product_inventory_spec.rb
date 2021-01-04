require 'rails_helper'

RSpec.describe DsProductInventory, type: :model do

  describe "associations" do
    it { should belong_to(:ds_product) }
    it { should belong_to(:ds_shop)}
  end
end
