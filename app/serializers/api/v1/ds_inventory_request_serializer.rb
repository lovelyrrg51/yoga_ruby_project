module Api::V1
  class DsInventoryRequestSerializer < ActiveModel::Serializer
    attributes :id, :quantity, :ds_asset_tag_id
    #embed :ids
    has_one :ds_product
    has_one :ds_product_inventory_request
  end
end
