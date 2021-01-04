module Api::V1
  class BhandaraItemSerializer < ActiveModel::Serializer
    attributes :id, :day, :item_name, :bhandara_detail_id
  end
end
