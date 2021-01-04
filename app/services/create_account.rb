# frozen_string_literal: true

class CreateAccount

  def self.call sign_up_params
    sadhak_profile = SadhakProfile.new(
      first_name: sign_up_params[:first_name],
      mobile: sign_up_params[:mobile],
      email: sign_up_params[:email],
    )

    sadhak_profile.build_user(
      name: sadhak_profile.first_name,
      password: sign_up_params[:password],
      email: sadhak_profile.email || '',
      contact_number: sadhak_profile.mobile,
    )

    sadhak_profile.save
    sadhak_profile
  end

end
