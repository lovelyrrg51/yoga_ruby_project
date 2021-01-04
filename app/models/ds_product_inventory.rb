class DsProductInventory < ApplicationRecord
  belongs_to :ds_product
  belongs_to :ds_shop
end
