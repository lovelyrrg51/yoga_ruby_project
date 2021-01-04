module V2
  class UserRegisteredEventsController < BaseController
    before_action :authenticate_user!

    def index
      render json: V2EventsDatatable.new(view_context)
    end

    def show
      @event = current_sadhak_profile.events.find(params[:id]).decorate
      respond_to do |format|
        format.js
      end
    end

  end
end
