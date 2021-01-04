# frozen_string_literal: true

module V2
  class BatchSadhakProfilesController < BaseController
    before_action :authenticate_user!

    def batch_regist
      batch_profiles = []
      batch_sadhak_profiles_params[:sadhak_profiles].each do |profile_params|
        profile = create_profile(profile_params.except(:_id))
        profile[:_id] = profile_params[:_id]
        batch_profiles << profile
      end
      render json: batch_profiles
    rescue StandardError => e
      Rollbar.error(e)
      @message = e.message
      render json: { error: @message }
    end

    private

    def batch_sadhak_profiles_params
      params.require(:batch_sadhak_profile).permit(:sadhak_profiles => [
          :name_of_guru, :spiritual_org_name, :status_notes, :event_id, :id, :username, :first_name, :last_name, :date_of_birth, :gender, :mobile, :email, :_id,
          address_attributes: %i[id first_line second_line country_id state_id other_state city_id other_city postal_code]
      ])
    end

    def create_profile(profile_params)
      sadhak_profile_params = profile_params.except(:address_attributes)
      address_params = profile_params[:address_attributes]
      result = CreateSadhakProfile.call(
          sadhak_profile_params: sadhak_profile_params,
          address_params: address_params,
          user: current_user
      )

      if result.success
        sadhak_profile = result.sadhak_profile
        {
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
        { error: result.error.message }
      end
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
