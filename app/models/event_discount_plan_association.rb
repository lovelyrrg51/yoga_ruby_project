class EventDiscountPlanAssociation < ApplicationRecord
  belongs_to :event
  belongs_to :discount_plan
  validates_uniqueness_of :event_id, scope: :discount_plan_id
end
