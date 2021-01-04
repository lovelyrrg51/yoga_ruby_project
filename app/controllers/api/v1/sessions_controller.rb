module Api::V1
  class SessionsController < BaseController
    before_action :authenticate_user!, only: [:show, :wp_current_user, :user_sign_out]
  
    def new
      user = User.find_for_database_authentication(user_params.slice(:username))
      if user.present?
        if user.valid_password?(user_params[:password])
          # auth_token = TokenIssuer.create_token(user, request)
          # user.authentication_token = auth_token
          # cookies.signed[:_shivyog_rails_api_session] = auth_token
          sadhak_extra_field = user.sadhak_profile.slice( :event_ids, :active_club_ids, :joined_club_ids, :sy_club_ids)
          sadhak_profiles = [user.sadhak_profile.as_json.merge(sadhak_extra_field)]
          address = user.sadhak_profile.try(:address).as_json
          address_extra_field = user.sadhak_profile.try(:address).slice(:db_state_id,:db_city_id,:db_country_id)
          user_extra_field = user.slice(:sadhak_profile_ids, :registration_center_ids)
          user_extra_field[:sadhak_profile_id]= user.sadhak_profile.id
          # render json: user, status: :created
          render json: {}.merge(**{user: user.as_json.merge(user_extra_field)}, **{addresses: [address.merge(address_extra_field)]}, **{sadhak_profiles: sadhak_profiles}), status: :created 
        else
          render json: {error: ['Password is not valid.']}, status: :unauthorized
        end
      else
        render json: {error: ['Username/SYID is invalid.']}, status: :unauthorized
      end
    end
  
    def show
      render json: current_user
    end
  
    def wp_current_user
      render json: current_user, serializer: WpUserSerializer, root: 'user'
    end
  
    def user_sign_out
      # cookies.delete(:_shivyog_rails_api_session)
      TokenIssuer.expire_token(current_user, request)
      render json: {success: 1}
    end
  
    def wp_login
      user = User.find_for_database_authentication(user_params.slice(:username))
      if user.present?
        if user.valid_password?(user_params[:password])
          # auth_token = TokenIssuer.create_token(user, request)
          # user.authentication_token = auth_token
          # cookies.signed[:_shivyog_rails_api_session] = auth_token
          sadhak_profiles = [user.sadhak_profile.as_json]
          address = user.sadhak_profile.try(:address).as_json
          extra_field = user.sadhak_profile.try(:address).slice(:db_state_id,:db_city_id,:db_country_id)
          # render json: user, status: :created
          render json: {}.merge(**{user: user}, **{address: address.merge(extra_field)}, **{sadhak_profiles: sadhak_profiles}), status: :created 
        else
          render json: {error: ['Password is not valid.']}, status: :unauthorized
        end
      else
        render json: {error: ['Username/SYID is invalid.']}, status: :unauthorized
      end
    end
  
    private
  
    def user_params
      params.require(:user).permit(:username, :password)
    end
  
  end
end
