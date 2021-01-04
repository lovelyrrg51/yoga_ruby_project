module Api::V1
  class DsAssetTagSerializer < ActiveModel::Serializer
    attributes :id, :name
    #embed :ids
    has_many :ds_products
  end
end
