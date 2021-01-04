module Api::V1
  class RolesController < BaseController
    before_action :authenticate_user!
    before_action :set_role, only: [:show, :edit, :update, :destroy]
    before_action :authorize_user, :except => :index
    after_action :verify_authorized, :except => :index
    after_action :verify_policy_scoped, :only => :index
  
    def index
      @roles = policy_scope(Role)
    end
  
    def show
    end
  
    def new
      @role = Role.new
    end
  
    def create
      @role = Role.new(role_params)
    end
  
    def edit
    end
  
    def update
    end
  
    def destroy
    end
  
    private
  
    def set_role
      @role = Role.find(params[:id])
    end
  
    def authorize_user
      authorize @role, :allowed?
    end
  
    def role_params
      params.require(:role).permit(:Role)
    end
  
  end
end
