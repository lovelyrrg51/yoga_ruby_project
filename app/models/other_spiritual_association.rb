class OtherSpiritualAssociation < ApplicationRecord
  acts_as_paranoid

  REQUIRED_FIELD = [
    :organization_name,
    :association_description,
    :associated_since_year,
    :associated_since_month,
    :duration_of_practice
  ]

  belongs_to :sadhak_profile

  after_save { self.sadhak_profile.check_profile_completeness }
end
