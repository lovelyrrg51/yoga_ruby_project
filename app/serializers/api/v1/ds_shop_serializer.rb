module Api::V1
  class DsShopSerializer < ActiveModel::Serializer
    attributes :id, :name, :description
    #embed :ids
    has_one :event
    has_many :ds_product_inventory_requests
  #   has_many :ds_products
  end
end
