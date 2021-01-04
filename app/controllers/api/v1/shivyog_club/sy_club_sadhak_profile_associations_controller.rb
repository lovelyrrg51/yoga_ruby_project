module Api::V1::ShivyogClub
  class SyClubSadhakProfileAssociationsController < ::Api::V1::BaseController
    before_action :authenticate_user!, except: [:index, :create]
    before_action :set_sy_club_sadhak_profile_association, only: [:show, :edit, :update, :destroy]
    respond_to :json
    skip_before_action :verify_authenticity_token, :only => [:index, :create]
  
    # GET /sy_club_sadhak_profile_associations
    def index
      @sy_club_sadhak_profile_associations = policy_scope( SyClubSadhakProfileAssociation)
      render json: @sy_club_sadhak_profile_associations
    end
  
    # GET /sy_club_sadhak_profile_associations/1
    def show
    end
  
    # GET /sy_club_sadhak_profile_associations/new
    def new
      @sy_club_sadhak_profile_association = SyClubSadhakProfileAssociation.new
    end
  
    # GET /sy_club_sadhak_profile_associations/1/edit
    def edit
    end
  
    # POST /sy_club_sadhak_profile_associations
    def create
      @sy_club_sadhak_profile_association = SyClubSadhakProfileAssociation.new(sy_club_sadhak_profile_association_params)
      if @sy_club_sadhak_profile_association.save
        render json: @sy_club_sadhak_profile_association
      else
         render json: @sy_club_sadhak_profile_association.errors, status: :unprocessable_entity
        # render json: {error: 1, message: @sy_club_sadhak_profile_association.errors }, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /sy_club_sadhak_profile_associations/1
    def update
      authorize @sy_club_sadhak_profile_association
      if @sy_club_sadhak_profile_association.update(sy_club_sadhak_profile_association_params)
        render json: @sy_club_sadhak_profile_association
      else
        render json: @sy_club_sadhak_profile_association.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /sy_club_sadhak_profile_associations/1
    def destroy
      authorize @sy_club_sadhak_profile_association
      sy_sadhak_association =  @sy_club_sadhak_profile_association.destroy
      render json: sy_sadhak_association
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_sy_club_sadhak_profile_association
        @sy_club_sadhak_profile_association = SyClubSadhakProfileAssociation.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def sy_club_sadhak_profile_association_params
        params.require(:sy_club_sadhak_profile_association).permit(:sadhak_profile_id, :sy_club_id, :sy_club_user_role_id, :status, :sy_club_validity_window_id)
      end
  end
end
