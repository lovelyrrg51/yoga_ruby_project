module Api::V1
  class LineItemSerializer < ActiveModel::Serializer
    attributes :id, :digital_asset_id, :order_id
  end
end
