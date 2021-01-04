class Ticket < ApplicationRecord
  include AASM
  include Filterable

  attr_accessor :current_user

  scope :ticketable_id, ->(ticketable_id) { where ticketable_id: ticketable_id }
  scope :ticketable_type, ->(ticketable_type) { where ticketable_type: ticketable_type }

  validates :title, presence: true, length: { maximum: 255 }

  belongs_to :ticketable, polymorphic: true
  belongs_to :user
  has_many :ticket_responses

  before_validation :check_validation

  enum priority: {
    low: 1,
    medium: 2,
    high: 3
  }

  enum status: {
    open: "open",
    closed: "closed",
    will_waiting_for_response_from_assignee: "will_waiting_for_response_from_assignee",
    will_waiting_for_response_from_creator: "will_waiting_for_response_from_creator"
  }

  aasm column: :status, enum: true do
    state :open, initial: true
    state :closed
  end

  private
  def check_validation
    if self.user.nil? and current_user.present?
      self.user = current_user
    end
  end
end
