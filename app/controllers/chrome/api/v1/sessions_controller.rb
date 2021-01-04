class Chrome::Api::V1::SessionsController < Chrome::Api::V1::BaseController
  before_action :authenticate_user!, only: [:current, :sign_out, :basic_user_details]

  def sign_in
    command = AuthenticateUser.call(user_params.slice(:username), user_params[:password], request, current_user)
    if command.success?
      render json: command.result, status: :created
    else
      render_error(command.errors.first, :unauthorized)
    end
  end

  def current
    render json: current_user, serializer: Chrome::Api::V1::CurrentUserSerializer, root: 'user'
  end

  def basic_user_details
    render json: current_user, serializer: Chrome::Api::V1::UserBasicDetailSerializer, root: 'user'
  end

  def sign_out
    TokenIssuer.expire_token(current_user, request)
    render_data('Successfully Signout.')
  end

  private

  def user_params
    params.require(:user).permit(:username, :password)
  end

end
