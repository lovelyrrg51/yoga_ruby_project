class SpiritualJourney < ApplicationRecord
  acts_as_paranoid

  REQUIRED_FIELD = [:source_info_type_id]

  validates :sadhak_profile_id, uniqueness: true
  belongs_to :sadhak_profile
  belongs_to :sub_source_type
  belongs_to :source_info_type

  validates :source_info_type, presence: true

  after_save { self.sadhak_profile.check_profile_completeness }
end
