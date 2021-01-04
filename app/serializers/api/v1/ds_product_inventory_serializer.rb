module Api::V1
  class DsProductInventorySerializer < ActiveModel::Serializer
    attributes :id
    has_one :ds_product
    has_one :ds_shop
  end
end
