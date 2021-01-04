class ProfessionalDetail < ApplicationRecord
  acts_as_paranoid

  REQUIRED_FIELD = [:highest_degree, :profession_id]
  NON_PROFESSIONAL_REQUIRED_FIELD = [:highest_degree, :profession_id]

  validates :sadhak_profile_id, uniqueness: true

  belongs_to :sadhak_profile
  belongs_to :profession

  after_save { self.sadhak_profile.check_profile_completeness }

  enum highest_degree: { b_tech: 0, mca: 1, mba: 2, msc: 3, bca: 4, be: 5, other: 6 }

  delegate :name, to: :profession, prefix: :profession, allow_nil: true

end
