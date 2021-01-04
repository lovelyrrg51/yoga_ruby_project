module Api::V1
  class EventCancellationPlanItemSerializer < ActiveModel::Serializer
    attributes :id, :days_before, :amount, :amount_type, :event_cancellation_plan_id
  end
end
