class TicketResponse < ApplicationRecord
  include Filterable

  scope :ticket_id, ->(ticket_id) { where ticket_id: ticket_id }

  belongs_to :ticket
  belongs_to :user
  has_one :attachment, as: :attachable

  enum status: {
    waiting_for_response: 1,
    waiting_for_none: 0
  }
end
