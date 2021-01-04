class ActivityEventTypePricingAssociation < ApplicationRecord
  belongs_to :event
  belongs_to :event_type_pricing

  scope :event_id, ->(event_id) { where(event_id: event_id) }
end
