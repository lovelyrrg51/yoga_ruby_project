class EventRegistrationCenterAssociation < ApplicationRecord
  belongs_to :event
  belongs_to :registration_center

  validates_uniqueness_of :registration_center_id, scope: :event_id
end
