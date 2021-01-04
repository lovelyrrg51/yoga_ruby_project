class UpdateSadhakProfileCompleteness

  def self.call(sadhak_profile)
    profile_completeness = 10
    profile_completeness +=12 if sadhak_profile.address.present?
    profile_completeness +=12 if sadhak_profile.professional_detail.present?
    # profile_completeness +=12 if sadhak_profile.spiritual_practice.present?
    profile_completeness +=12 if sadhak_profile.advance_profile.present?
    # profile_completeness += 12 if sadhak_profile.spiritual_journey.present?
    profile_completeness += 14 if sadhak_profile.other_spiritual_associations.present?
    profile_completeness += 16 if sadhak_profile.aspects_of_life.present?

    sadhak_profile.update_columns(profile_completeness: profile_completeness)
  end

end
