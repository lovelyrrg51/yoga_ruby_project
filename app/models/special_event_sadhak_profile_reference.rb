class SpecialEventSadhakProfileReference < ApplicationRecord
  belongs_to :special_event_sadhak_profile_other_info
  belongs_to :sadhak_profile

  validates_uniqueness_of :sadhak_profile_id, scope: :special_event_sadhak_profile_other_info_id, message: 'is already taken. Please use two different sadhak profiles for references.'

  before_create :check_valid_sadhak_profiles

  private

  def check_valid_sadhak_profiles
    syid = "sy#{sadhak_profile_id.to_s[/-?\d+/].to_i}".upcase
    unless SadhakProfile.find_by_syid(syid)
      raise "SY#{sadhak_profile_id} is not a valid Sadhak Profile. Please enter a valid Sadhak Profile."
      throw(:abort)
    end
  end
end