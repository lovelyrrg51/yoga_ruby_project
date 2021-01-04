class EventSadhakQuestionnaire < ApplicationRecord
  belongs_to :event
  belongs_to :sadhak_profile
  serialize :data, JSON
  scope :event_id, ->(event_id){where(event_id: event_id)}
end
