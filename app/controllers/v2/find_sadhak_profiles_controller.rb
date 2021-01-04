module V2
  class FindSadhakProfilesController < BaseController
    before_action :authenticate_user!

    def find
      first_name = params[:first_name].strip.downcase
      query = params[:mobile_email_syid].strip
      sadhak_profile = FindSadhakProfile.by_query_and_first_name query, first_name

      if sadhak_profile
        render json: {
            id: sadhak_profile.id,
            full_name: sadhak_profile.full_name,
            gender: sadhak_profile.gender,
            obscure_email: Utilities::MaskEmail.call(sadhak_profile.email),
            obscure_mobile: Utilities::Mobile.new(sadhak_profile.mobile).masked_number,
            city: sadhak_profile.city_name,
            state: sadhak_profile.state_name,
            country: sadhak_profile.country_name,
            is_verified: sadhak_profile.is_verified?,
            slug: sadhak_profile.slug
        }.merge(get_verification_link(sadhak_profile))

      else
        head :not_found
      end
    rescue => e
      Rollbar.error(e)
      head :internal_server_error
    end

    def get_verification_link(sadhak_profile)
      email = nil, mobile = nil
      email = send_email_verification_v2_sadhak_profile_verify_sadhak_profile_path(sadhak_profile) if sadhak_profile.email.present? && !sadhak_profile.is_email_verified?
      mobile = send_mobile_verification_v2_sadhak_profile_verify_sadhak_profile_path(sadhak_profile) if sadhak_profile.mobile.present? && !sadhak_profile.is_mobile_verified?
      {
        verify_link: {
            email: email,
            mobile: mobile
        }
      }
    end

  end
end
