class SyClubReference < ApplicationRecord
  acts_as_paranoid

  belongs_to :sy_club
  belongs_to :sadhak_profile

  scope :sy_club_id, ->(sy_club_id) { where(sy_club_id: sy_club_id) }
end
