module V2
  class SadhakProfilesController < BaseController
    before_action :authenticate_user!

    def show
      sadhak_profile = SadhakProfile.friendly.find params[:id]
      authorize sadhak_profile

      render json: EditSadhakProfilePresenter.new(sadhak_profile).as_json
    end

    def new
    end

    def create
      result = CreateSadhakProfile.call(
        sadhak_profile_params: sadhak_profile_params,
        address_params: address_params,
        user: current_user
      )

      if result.success
        result.sadhak_profile.send_verification_token rescue nil
        result.sadhak_profile.save
        render json: {
          success: true,
          redirect_path: v2_sadhak_profile_verify_sadhak_profile_path(result.sadhak_profile)
        }
      else
        render json: { success: false, message: result.error.message },
          status: :unprocessable_entity
      end
    end

    def family_profiles
      authorize current_user.sadhak_profile
      @sadhak_profiles = ([current_user.sadhak_profile] + current_user.sadhak_profiles).uniq
    end

    def edit
      @sadhak_profile = SadhakProfile.friendly.find params[:id]
      authorize @sadhak_profile
      @event_orders ||= current_user.event_orders.where(status: "success").where.not(sy_club_id: nil)
      @user = current_user
    end

    def update
      sadhak_profile = SadhakProfile.friendly.find params[:id]
      authorize sadhak_profile

      result = UpdateSadhakProfile.call(
        sadhak_profile: sadhak_profile,
        sadhak_profile_params: sadhak_profile_params,
        address_params: address_params
      )

      if result.success
        # TODO: only send email or mobile verification as needed
        if result.email_verification_needed || result.mobile_verification_needed
          result.sadhak_profile.send_verification_token rescue nil
          result.sadhak_profile.save
          redirect_path = v2_sadhak_profile_verify_sadhak_profile_path(result.sadhak_profile)
        else
          flash[:success] = 'Sadhak profile is updated!'
          redirect_path = edit_v2_sadhak_profile_path(result.sadhak_profile)
        end

        render json: {
          success: true,
          redirect_path: redirect_path
        }
      else
        render json: { success: false, message: result.error.message },
          status: :unprocessable_entity
      end
    end

    private

    def sadhak_profile_params
      params.require(:sadhak_profile).permit :first_name, :last_name, :gender,
        :date_of_birth, :email, :mobile
    end

    def address_params
      params.require(:address).permit :first_line, :second_line, :city_id,
        :state_id, :country_id, :other_state, :other_city, :postal_code
    end

  end
end
