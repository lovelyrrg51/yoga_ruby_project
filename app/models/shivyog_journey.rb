class ShivyogJourney < ApplicationRecord
  acts_as_paranoid

  belongs_to :sadhak_profile

  validates :sadhak_profile_id, uniqueness: true

end
