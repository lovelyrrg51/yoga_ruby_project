module Api::V1
  class DoctorsProfilesController < BaseController
    before_action :authenticate_user!, except: [:create, :update]
    before_action :set_doctors_profile, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /doctors_profiles
    def index
      @doctors_profiles = policy_scope(DoctorsProfile)
      render json: @doctors_profiles
    end
  
    # GET /doctors_profiles/1
    def show
      authorize @doctors_profile
      render json: @doctors_profile
    end
  
    # GET /doctors_profiles/new
    def new
      @doctors_profile = DoctorsProfile.new
    end
  
    # GET /doctors_profiles/1/edit
    def edit
    end
  
    # POST /doctors_profiles
    def create
      @doctors_profile = DoctorsProfile.new(doctors_profile_params)
      # authorize @doctors_profile
      if @doctors_profile.save
        render json: @doctors_profile
      else
        render json: @doctors_profile.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /doctors_profiles/1
    def update
      # authorize @doctors_profile
      if @doctors_profile.update(doctors_profile_params)
        render json: @doctors_profile
      else
        render json: @doctors_profile.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /doctors_profiles/1
    def destroy
      authorize @doctors_profile
      res = @doctors_profile.destroy
      render json: res
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_doctors_profile
        @doctors_profile = DoctorsProfile.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def doctors_profile_params
        params.require(:doctors_profile).permit!
      end
  end
end
