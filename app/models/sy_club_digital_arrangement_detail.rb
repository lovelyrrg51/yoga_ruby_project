class SyClubDigitalArrangementDetail < ApplicationRecord
  belongs_to :sy_club
  validates :lcd_size, numericality: { greater_than_or_equal_to: 42, allow_nil: true, only_integer: true }
end
