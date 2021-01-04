module Api::V1
  class BaseController < ApplicationController
  
    include JwtHelper
  
    protect_from_forgery with: :null_session, prepend: true
  
    before_action :destroy_session
  
    def current_user
      @user || find_current_user
    end
  
    def authenticate_user!
      raise Pundit::NotAuthorizedError, 'Unauthorized user.' unless current_user
    end
  
    def routing_error
      render json: {error: ['Routing Error. API::BASE']}, status: :not_found
    end
  
    private
  
    def destroy_session
      request.session_options[:skip] = true
    end
  
    def user_not_authorized
  
      render json: {error: ['You are not authorized to perform this action. API::BASE.']}, status: :unauthorized
  
    end
  
    def stream_file(filename, extension)
      response.headers["Content-Type"] = "application/octet-stream"
      response.headers["Content-Disposition"] = "attachment; filename=#{filename}-#{Time.now.to_i}.#{extension}"
  
      yield response.stream
      ensure
        response.stream.close
    end
  
    def render_404
      render json: {error: ['Not found. API::BASE.']}, status: :not_found
    end
  
    def render_400
      render json: {error: ['Bad Request. API::BASE.']}, status: :bad_request
    end
  
    def error_occurred(exception)
  
      status_code = ActionDispatch::ExceptionWrapper.new(request.env, exception).status_code
  
      Rails.logger.info exception.backtrace
  
      render json: {error: [exception.message + ' - API::BASE.']}, status: status_code
  
    end
  
    def jwt_token
      request.headers['Authorization'].to_s.split(' ').last || request.headers['X-User-Token']
    end
  
    def find_current_user
  
      if authentication_token = find_key_in_jwt('authentication_token', jwt_token)
  
        token = AuthenticationToken.find_by_body(authentication_token)
  
        token.touch(:last_used_at) if token.present? && token.last_used_at < 10.minutes.ago
  
        @user = token.try(:user)
  
      elsif (params[:user_username].present? and params[:user_token].present?) || (request.headers['X-User-Username'].present? and request.headers['X-User-Token'].present?)
  
        username = (params[:user_username] || request.headers['X-User-Username']).to_s.force_encoding('iso-8859-1').encode('utf-8')
  
        authentication_token = params[:user_token] || request.headers['X-User-Token']
  
        @user = User.where('username=? AND authentication_token=?', username, authentication_token).first
  
      end
  
      @user
    end
  end
end
