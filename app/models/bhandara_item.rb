class BhandaraItem < ApplicationRecord
  belongs_to :bhandara_detail
  validates :day, :bhandara_detail_id, uniqueness: true
end
