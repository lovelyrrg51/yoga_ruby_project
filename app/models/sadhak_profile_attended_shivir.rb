class SadhakProfileAttendedShivir < ApplicationRecord
  acts_as_paranoid

  scope :sadhak_profile_id, lambda { |sadhak_profile_id| where(sadhak_profile_id: sadhak_profile_id) }
  belongs_to :sadhak_profile
end
