require 'rails_helper'

RSpec.describe DsAssetTag, type: :model do

  describe "associations" do
    it { should have_many(:ds_asset_tag_collections) }
    it { should have_many(:ds_product_asset_tag_associations) }
    it { should have_many(:ds_products).through(:ds_product_asset_tag_associations) }
  end
end
