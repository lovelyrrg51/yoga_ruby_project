module OmniauthService

  def self.from_google auth
    user = User.find_by(oauth_provider: auth.provider, oauth_uid: auth.uid)
    return user if user

    user = User.where(email: auth.info.email).first_or_initialize
    user.oauth_provider = auth.provider
    user.oauth_uid = auth.uid
    user.name = auth.info.first_name
    user.last_name = auth.info.last_name
    user.oauth_image = auth.info.image
    user.is_email_verified = auth.info.email_verified
    user.password = Devise.friendly_token[0, 20] if user.new_record?

    sadhak_profile = user.sadhak_profile || SadhakProfile.new(
      user: user,
      first_name: auth.info.first_name,
      last_name: auth.info.last_name,
      email: auth.info.email,
      remote_avatar_url: auth.info.image
    )

    ApplicationRecord.transaction do
      user.save!
      sadhak_profile.save!
      # TODO REFACTOR temp hack to correct is_email_verified value because of
      # sadhak_profile_before_save callback in SadhakProfile
      sadhak_profile.update_attribute :is_email_verified, auth.info.email_verified
    end

    user
  rescue => e
    Rollbar.error(e)
    user
  end

end
