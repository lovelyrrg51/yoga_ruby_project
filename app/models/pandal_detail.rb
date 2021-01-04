class PandalDetail < ApplicationRecord
  enum seating_type: { matresses: 1, chairs: 2, both: 0 }

  validates :len, :width, :seating_type, :arrangement_details, :event_id,
    :chairs_count, presence: true
  validates :len, :width, numericality: true, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }
  validates  :matresses_count, :chairs_count, numericality: { only_integer: true }
  validates :event_id, uniqueness: true

  belongs_to :event
end
