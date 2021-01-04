module Api::V1
  class AdvanceProfilesController < BaseController
    # Allowed update call for non logged in when we made Advance profile mandaterory - Jan 17, 2017
    before_action :authenticate_user!, except: [:create, :show, :index, :update]
    before_action :set_advance_profile, only: [:show, :edit, :update, :destroy]
    skip_before_action :verify_authenticity_token, :only => [:create, :show, :update]
    respond_to :json
  #   serialization_scope :current_user
    # GET /advance_profiles
    def index
      @advance_profiles = policy_scope(AdvanceProfile)
      render json: @advance_profiles
    end
  
    # GET /advance_profiles/1
    def show
      authorize @advance_profile
      render json: @advance_profile
    end
  
    # GET /advance_profiles/new
    def new
      @advance_profile = AdvanceProfile.new
    end
  
    # GET /advance_profiles/1/edit
    def edit
    end
  
    # POST /advance_profiles
    def create
      @advance_profile = AdvanceProfile.new(advance_profile_params)
  #     authorize @advance_profile
      if @advance_profile.save
        render json: @advance_profile
      else
        render json: @advance_profile.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /advance_profiles/1
    def update
      # Authorization removed - 18 Jan 2017
      # authorize @advance_profile
      if @advance_profile.update(advance_profile_params)
        render json: @advance_profile
      else
        render json: @advance_profile.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /advance_profiles/1
    def destroy
      authorize @advance_profile
      res = @advance_profile.destroy
      render json: res
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_advance_profile
        @advance_profile = AdvanceProfile.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def advance_profile_params
        params.require(:advance_profile).permit(:faith, :any_legal_proceeding, :attended_any_shivir, :photograph_url, :photograph_path, :photo_id_proof_type, :photo_id_proof_number, :photo_id_proof_url, :photo_id_proof_path, :address_proof_type, :address_proof_url, :address_proof_path, :sadhak_profile_id, :address_proof_type_id, :photo_id_proof_type_id)
      end
  end
end
