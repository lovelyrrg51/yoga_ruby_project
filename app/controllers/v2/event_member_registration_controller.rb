module V2
  class EventMemberRegistrationController < BaseController
    include EventOrdersHelper
    include EventsHelper

    def search_sadhak_profile
      first_name = params[:sadhak_profiles][:first_name].to_s.strip.downcase
      syid = params[:sadhak_profiles][:syid]
      sadhak_profile = FindSadhakProfile.by_query_and_first_name syid, first_name

      if sadhak_profile
        render json: {
          sadhak_profile: {
            id: sadhak_profile.id,
            first_name: sadhak_profile.first_name,
            last_name: sadhak_profile.last_name,
            email: sadhak_profile.email,
            gender: sadhak_profile.gender,
            mobile: sadhak_profile.mobile,
            address: sadhak_profile.full_address,
            city: sadhak_profile.city_name,
            state: sadhak_profile.state_name,
            country: sadhak_profile.country_name,
            postal_code: sadhak_profile.postal_code
          }
        }
      else
        head :not_found
      end
    end
  end
end
