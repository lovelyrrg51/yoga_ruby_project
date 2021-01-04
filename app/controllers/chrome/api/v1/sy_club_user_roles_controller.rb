class Chrome::Api::V1::SyClubUserRolesController < Chrome::Api::V1::BaseController
  before_action :authenticate_user!
  respond_to :json

  # GET /sy_club_user_roles
  def index
    @sy_club_user_roles = SyClubUserRole.all
    render json: @sy_club_user_roles, each_serializer: Chrome::Api::V1::SyClubUserRoleSerializer
  end

end
