class Chrome::Api::V1::BaseController < ApplicationController
  
  protect_from_forgery with: :null_session, prepend: true

  before_action :destroy_session

  def current_user
    @command ||= AuthorizeApiRequest.call(request.headers)
    @command.result
  end

  def authenticate_user!
    raise Pundit::NotAuthorizedError, 'Unauthorized user.' unless current_user
  end

  def routing_error
    render_error('Routing Error. CHROME::API::BASE', :not_found)
  end

  def render_data(data, status = :ok)

    data = data.is_a?(Hash) ? data : { data: data }

    data = data.merge({ code: Rack::Utils::SYMBOL_TO_STATUS_CODE[status] })

    render json: data, status: status

  end

  def render_error(message, status = :unprocessable_entity)
    render_data({ error: message }, status)
  end

  private

  def destroy_session
    request.session_options[:skip] = true
  end

  def user_not_authorized
    render_error('You are not authorized to perform this action. CHROME::API::BASE.', :unauthorized)
  end

  def render_404
    render_error('Not found. CHROME::API::BASE.', :not_found)
  end

  def render_400
    render_error('Bad Request. CHROME::API::BASE.', :bad_request)
  end

  def error_occurred(exception)

    status_code = ActionDispatch::ExceptionWrapper.new(request.env, exception).status_code

    logger.info exception.backtrace

    render_error("#{exception.message} - CHROME::API::BASE.", status_code)

  end
end
