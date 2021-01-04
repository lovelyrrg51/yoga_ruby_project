module Api::V1
  class DsProductDetailSerializer < ActiveModel::Serializer
    attributes :id, :name, :description, :price, :availability, :video_url,:ds_product_id
  end
end
