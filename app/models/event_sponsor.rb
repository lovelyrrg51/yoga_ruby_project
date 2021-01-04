class EventSponsor < ApplicationRecord
  include Filterable
  acts_as_paranoid

  scope :event_id, ->(event_id) { where event_id: event_id }

  belongs_to :sadhak_profile
  belongs_to :event
end
