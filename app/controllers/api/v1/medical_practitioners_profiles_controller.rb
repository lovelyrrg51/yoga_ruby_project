module Api::V1
  class MedicalPractitionersProfilesController < BaseController
    before_action :authenticate_user!, except: [:index, :show, :create, :update]
    before_action :set_medical_practitioners_profile, only: [:show, :edit, :update, :destroy]
  #   before_action :authenticate_user!, except: [:create, :index]
    skip_before_action :verify_authenticity_token, :only => [:index, :create, :update]
    respond_to :json
  #   skip_before_action :verify_authenticity_token, :only => [:create, :index]
  
    # GET /medical_practitioners_profiles
    def index
      @medical_practitioners_profiles = MedicalPractitionersProfile.all
      render json: @medical_practitioners_profiles
    end
  
    # GET /medical_practitioners_profiles/1
    def show
      @medical_practitioners_profile = MedicalPractitionersProfile.find(params[:id])
      render json: @medical_practitioners_profile
    end
  
    # GET /medical_practitioners_profiles/new
    def new
      @medical_practitioners_profile = MedicalPractitionersProfile.new
    end
  
    # GET /medical_practitioners_profiles/1/edit
    def edit
    end
  
    # POST /medical_practitioners_profiles
    def create
      @medical_practitioners_profile = MedicalPractitionersProfile.new(medical_practitioners_profile_params)
      if @medical_practitioners_profile.save
        render json: @medical_practitioners_profile
      else
        render json: @medical_practitioners_profile.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /medical_practitioners_profiles/1
    def update
      if @medical_practitioners_profile.update(medical_practitioners_profile_params)
        render json: @medical_practitioners_profile
      else
        render json: @medical_practitioners_profile.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /medical_practitioners_profiles/1
    def destroy
     mpp =  @medical_practitioners_profile.destroy
      render json: mpp
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_medical_practitioners_profile
        @medical_practitioners_profile = MedicalPractitionersProfile.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def medical_practitioners_profile_params
        params.require(:medical_practitioners_profile).permit(:medical_degree, :practiced_integrative_health_care, :current_professional_role, :other_role, :work_enviroment, :interested_in_panel_discussion, :interested_in_volunteering, :other_speciality, :sadhak_profile_id, :medical_practitioner_speciality_area_id)
      end
  end
end
