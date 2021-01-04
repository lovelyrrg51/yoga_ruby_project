module Api::V1
  class DsProductSerializer < ActiveModel::Serializer
    attributes :id
    #embed :ids
    has_one :ds_product_detail, include: true
    has_many :ds_asset_tags
  end
end
