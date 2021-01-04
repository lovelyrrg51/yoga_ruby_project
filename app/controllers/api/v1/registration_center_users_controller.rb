module Api::V1
  class RegistrationCenterUsersController < BaseController
    before_action :authenticate_user!
    before_action :set_registration_center_user, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /registration_center_users
    def index
      @registration_center_users = policy_scope(RegistrationCenterUser)
      render json: @registration_center_users
    end
  
    # GET /registration_center_users/1
    def show
    end
  
    # GET /registration_center_users/new
    def new
      @registration_center_user = RegistrationCenterUser.new
    end
  
    # GET /registration_center_users/1/edit
    def edit
    end
  
    # POST /registration_center_users
    def create
      @registration_center_user = RegistrationCenterUser.new(registration_center_user_params)
      authorize @registration_center_user
      if @registration_center_user.save
        render json: @registration_center_user
      else
        render json: @registration_center_user.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /registration_center_users/1
    def update
      authorize @registration_center_user
      if @registration_center_user.update(registration_center_user_params)
        render json: @registration_center_user
      else
        render json: @registration_center_user.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /registration_center_users/1
    def destroy
      authorize @registration_center_user
      rcu = @registration_center_user.destroy
      render json: rcu
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_registration_center_user
        @registration_center_user = RegistrationCenterUser.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def registration_center_user_params
        params.require(:registration_center_user).permit(:user_id, :registration_center_id)
      end
  end
end
