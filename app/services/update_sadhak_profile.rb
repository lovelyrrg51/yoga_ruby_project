class UpdateSadhakProfile

  def self.call sadhak_profile:, sadhak_profile_params:, address_params:
    address = sadhak_profile.address || sadhak_profile.build_address
    sadhak_profile.assign_attributes sadhak_profile_params

    sadhak_profile.validate!
    email_verification_needed = sadhak_profile.email_changed?
    mobile_verification_needed = sadhak_profile.mobile_changed?

    ApplicationRecord.transaction do
      sadhak_profile.save!
      address.update! address_params
      sadhak_profile.user.update!(
        email: sadhak_profile.email,
        contact_number: sadhak_profile.mobile
      )
    end

    OpenStruct.new(
      success: true,
      sadhak_profile: sadhak_profile.reload,
      email_verification_needed: email_verification_needed,
      mobile_verification_needed: mobile_verification_needed
    )
  rescue => e
    OpenStruct.new(success: false, sadhak_profile: sadhak_profile, error: e)
  end

end
