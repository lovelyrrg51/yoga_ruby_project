class TicketGroup < ApplicationRecord
  validates :name, presence: true, length: { maximum: 255 }
  validates_uniqueness_of :name, case_sensitive: false

  has_many :user_ticket_group_associations
  has_many :users, through: :user_ticket_group_associations

  has_many :ticket_types
  has_many :tickets, through: :ticket_types

  scope :ticket_group_name, ->(ticket_group_name) { where("name ILIKE ?", "%#{ticket_group_name}%") }
end
