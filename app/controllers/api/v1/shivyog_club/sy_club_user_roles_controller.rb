module Api::V1::ShivyogClub
  class SyClubUserRolesController < ::Api::V1::BaseController
     before_action :authenticate_user!, except: [:index, :create]
    before_action :set_sy_club_user_role, only: [:show, :edit, :update, :destroy]
    skip_before_action :verify_authenticity_token, :only => [:index, :create]
    respond_to :json
  
    # GET /sy_club_user_roles
    def index
      @sy_club_user_roles = SyClubUserRole.all
      render json: @sy_club_user_roles, each_serializer: Chrome::Api::V1::SyClubUserRoleSerializer, root: 'sy_club_user_roles', adapter: :json
    end
  
    # GET /sy_club_user_roles/1
    def show
    end
  
    # GET /sy_club_user_roles/new
    def new
      @sy_club_user_role = SyClubUserRole.new
    end
  
    # GET /sy_club_user_roles/1/edit
    def edit
    end
  
    # POST /sy_club_user_roles
    def create
      @sy_club_user_role = SyClubUserRole.new(sy_club_user_role_params)
      if @sy_club_user_role.save
        render json: @sy_club_user_roles
      else
        render json: @sy_club_user_role.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /sy_club_user_roles/1
    def update
      if @sy_club_user_role.update(sy_club_user_role_params)
        render json: @sy_club_user_roles
      else
        render json: @sy_club_user_role.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /sy_club_user_roles/1
    def destroy
      sy_cr = @sy_club_user_role.destroy
      render json: sy_cr
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_sy_club_user_role
        @sy_club_user_role = SyClubUserRole.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def sy_club_user_role_params
        params.require(:sy_club_user_role).permit(:role_name)
      end
  end
end
