require 'rails_helper'

RSpec.describe DsProduct, type: :model do

  describe "associations" do
    it { should have_one(:ds_product_detail) }
    it { should have_many(:ds_product_asset_tag_associations) }
    it { should have_many(:ds_asset_tags).through(:ds_product_asset_tag_associations) }
    it { should have_many(:ds_product_inventories) }
    it { should have_many(:ds_shops).through(:ds_product_inventories) }
    # it { should belong_to(:imageable) }
    # it { should have_many(:ds_product_inventory_requests) }
    it { should have_many(:ds_inventory_requests).through(:ds_product_inventory_requests) }
    it { should belong_to(:ds_asset_tag) }
  end
end
