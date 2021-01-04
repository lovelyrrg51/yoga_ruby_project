class EventPrerequisitesEventType < ApplicationRecord
  belongs_to :event, inverse_of: :event_prerequisites_event_types
  belongs_to :event_type
end
