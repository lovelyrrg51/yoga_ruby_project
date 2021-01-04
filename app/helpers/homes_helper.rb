module HomesHelper
  def is_eligible_to_download_shivir_card?(event_registration = nil)

    sadhak_profile = event_registration.try(:sadhak_profile)

    sadhak_profile.present? && event_registration.event.shivir_card_enabled? && EventRegistration.valid_registration_statuses.include?(EventRegistration.statuses[event_registration.status]) && sadhak_profile.present? && sadhak_profile.advance_profile.present? && sadhak_profile.advance_profile.advance_profile_photograph.present? && sadhak_profile.advance_profile.advance_profile_identity_proof.present? && sadhak_profile.pp_success? && sadhak_profile.pi_success? && event_registration.event.event_start_date.present? && event_registration.event.event_start_date >= (Date.today - 1.day)
  end

  def entry_card_download_error_text(event_registration = nil)

    sadhak_profile = event_registration.try(:sadhak_profile)

    return "No registration found." unless event_registration.present?

    return "Shivir Cards is not enabled." unless event_registration.event.shivir_card_enabled?

    return "Registration no more valid." unless EventRegistration.valid_registration_statuses.include?(EventRegistration.statuses[event_registration.status])

    return "Sadhak Profile is missing." unless sadhak_profile.present?

    return "Advance Profile is missing." unless sadhak_profile.advance_profile.present?

    return "Profile Photo is not found." unless sadhak_profile.advance_profile.advance_profile_photograph.present?

    return "Photo Id is not found." unless sadhak_profile.advance_profile.advance_profile_identity_proof.present?

    return "Photo and Photo Id is under approval." if sadhak_profile.pp_pending? || sadhak_profile.pi_pending?

    return "Photo and Photo Id is rejected." if sadhak_profile.pp_rejected? && sadhak_profile.pi_rejected?

    return "Event is closed." unless event_registration.event.event_start_date.present? && event_registration.event.event_start_date >= (Date.today - 1.day)

    'Not Available.'

  end
end
