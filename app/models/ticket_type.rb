class TicketType < ApplicationRecord
  validates :ticket_type, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }
  validates :ticket_group_id, presence: true, numericality: true

  belongs_to :ticket_group
  has_many :tickets

  scope :ticket_type_name, ->(ticket_type_name) { where("ticket_type ILIKE ?", "%#{ticket_type_name}%") }
  scope :ticket_group_name, ->(ticket_group_name) {joins(:ticket_group).where("ticket_groups.name ILIKE ?", "%#{ticket_group_name}%") }

  delegate :name, to: :ticket_group, prefix: true
end
