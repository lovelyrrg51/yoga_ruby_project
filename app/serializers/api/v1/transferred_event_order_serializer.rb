module Api::V1
  class TransferredEventOrderSerializer < ActiveModel::Serializer
    attributes :id, :child_event_order_id, :parent_event_order_id
  end
end
