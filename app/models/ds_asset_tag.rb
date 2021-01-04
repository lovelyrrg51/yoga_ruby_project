class DsAssetTag < ApplicationRecord
  has_many :ds_asset_tag_collections
  has_many :ds_product_asset_tag_associations
  has_many :ds_products, through: :ds_product_asset_tag_associations
end
