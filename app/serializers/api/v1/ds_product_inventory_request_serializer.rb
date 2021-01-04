module Api::V1
  class DsProductInventoryRequestSerializer < ActiveModel::Serializer
    attributes :id
    #embed :ids
    has_many :ds_inventory_requests
    has_one :ds_shop
  end
end
