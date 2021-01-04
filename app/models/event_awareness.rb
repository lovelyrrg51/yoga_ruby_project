class EventAwareness < ApplicationRecord
  validates :budget, :event_id, presence: true
  validates :budget, numericality: true, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }
  belongs_to :event_awareness_type
  belongs_to :event
end
