class Chrome::Api::V2::SessionsController < Chrome::Api::V2::BaseController

    def sign_in
        begin
            user = User.find_for_database_authentication(user_params.slice(:username))

            raise 'Username/SYID is invalid.' unless user.present?

            raise 'Password is not valid.' unless user.valid_password?(user_params[:password])

            user.authentication_token = get_token(user)

        rescue Exception => e
            @error_msg = e.message
        ensure
            if @error_msg.present?
                render json: @error_msg, status: :unauthorized
            else
                render json: { user: Chrome::Api::V2::SignInUserSerializer.new(user).as_json }
            end
        end
    end

    def get_user
        begin

            raise "Invalid User." unless current_user.present?

            current_user.authentication_token = get_token(current_user)

        rescue Exception => e
            @error_msg = e.message
        ensure
            if @error_msg.present?
                render json: @error_msg, status: :unauthorized
            else
                render json: { user: Chrome::Api::V2::SignInUserSerializer.new(current_user).as_json }
            end
        end
    end
  
    private
  
    def user_params
      params.require(:user).permit(:username, :password)
    end

    def user_details_params
        params.permit(:auth_token)
    end
  
  end
  