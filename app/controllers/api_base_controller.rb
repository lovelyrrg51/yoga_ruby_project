class ApiBaseController < ApplicationController

  respond_to :json

  skip_before_action :verify_authenticity_token

  before_action :destroy_session

  rescue_from ::Exception, with: :error_occurred
  rescue_from ::NameError, with: :error_occurred
  rescue_from ::ActionController::ParameterMissing, with: :render_400
  rescue_from ::ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ::ActiveRecord::RecordInvalid, with: :error_occurred
  rescue_from ActionController::RoutingError, with: :routing_error
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def current_user
    @command ||= AuthorizeApiRequest.call(request.headers)
    @command.result
  end

  def authenticate_user!
    raise Pundit::NotAuthorizedError, 'Unauthorized user.' unless current_user
  end

  def routing_error
    render_error('Routing Error.', :not_found)
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
    render_error('You are not authorized to perform this action.', :unauthorized)
  end

  def render_404
    render_error('Not found.', :not_found)
  end

  def render_400
    render_error('Bad Request.', :bad_request)
  end

  def error_occurred(exception)
    status_code = ActionDispatch::ExceptionWrapper.new(request.env, exception).status_code
    Rollbar.error(exception)
    render_error("#{exception.message}", Rack::Utils::HTTP_STATUS_CODES[status_code].gsub(" ", "").underscore.to_sym)
  end
end
