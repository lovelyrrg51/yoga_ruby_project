class AdvisoryCounsil < ApplicationRecord
  acts_as_paranoid

  belongs_to :sadhak_profile
  belongs_to :sy_club
end
