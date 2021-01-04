require 'rails_helper'

RSpec.describe DsShop, type: :model do

  describe "associations" do

    it { should belong_to(:event) }
    it { should have_many(:ds_product_inventories)}
    it { should have_many(:ds_products).through(:ds_product_inventories)}
    it { should have_many(:ds_product_inventory_requests)}
  end
end
