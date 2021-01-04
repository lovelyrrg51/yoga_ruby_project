class SyClubEventTypeAssociation < ApplicationRecord
  include AASM
  include Filterable

  belongs_to :sy_club
  belongs_to :event_type

  scope :sy_club_id, ->(sy_club_id) { where sy_club_id:  sy_club_id}

  enum status:{
    pending:0,
    approve: 1
  }

  aasm column: :status, enum: true do
    state :approve, initial: true
    state :pending

    event :approve do
      transitions from: [:pending], to: :approve
    end
  end
end
