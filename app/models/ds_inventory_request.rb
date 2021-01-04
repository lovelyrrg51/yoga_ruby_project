class DsInventoryRequest < ApplicationRecord
  belongs_to :ds_product
  belongs_to :ds_product_inventory_request
  validates :ds_product_inventory_request_id, presence: true
end
