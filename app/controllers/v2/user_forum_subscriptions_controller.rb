module V2
  class UserForumSubscriptionsController < BaseController
    before_action :authenticate_user!

    def index
      render json: V2SyClubsDatatable.new(view_context)
    end

    def show
      @sy_club = SyClub.friendly.find(params[:id])
      respond_to do |format|
        format.js
      end
    end

  end
end
