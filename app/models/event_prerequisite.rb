class EventPrerequisite < ApplicationRecord
  belongs_to :cannonical_event
  belongs_to :prerequisite_cannonical_event,
    class_name: 'CannonicalEvent',
    foreign_key: :prerequisite_cannonical_event_id
end
