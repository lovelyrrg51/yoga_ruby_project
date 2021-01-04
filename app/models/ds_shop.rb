class DsShop < ApplicationRecord
  belongs_to :event
  has_many :ds_product_inventories
  has_many :ds_products, through: :ds_product_inventories
  has_many :ds_product_inventory_requests
end
