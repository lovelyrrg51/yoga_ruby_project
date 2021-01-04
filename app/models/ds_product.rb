class DsProduct < ApplicationRecord
  has_one :ds_product_detail
  has_many :ds_product_asset_tag_associations
  has_many :ds_asset_tags, through: :ds_product_asset_tag_associations
  has_many :ds_product_inventories
  has_many :ds_shops, through: :ds_product_inventories
  belongs_to :imageable, polymorphic: true
  has_many :ds_product_inventory_requests
  has_many :ds_inventory_requests, through: :ds_product_inventory_requests
  belongs_to :ds_asset_tag
end
