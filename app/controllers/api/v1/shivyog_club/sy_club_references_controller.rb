module Api::V1::ShivyogClub
  class SyClubReferencesController < ::Api::V1::BaseController
    before_action :authenticate_user!, except: [:index, :create]
    before_action :set_sy_club_reference, only: [:show, :edit, :update, :destroy]
    before_action :locate_collection, :only => :index
    skip_before_action :verify_authenticity_token, :only => [:index, :create]
  
    # GET /sy_club_references
    def index
      render json: @sy_club_references
    end
  
    # GET /sy_club_references/1
    def show
    end
  
    # GET /sy_club_references/new
    def new
      @sy_club_reference = SyClubReference.new
    end
  
    # GET /sy_club_references/1/edit
    def edit
    end
  
    # POST /sy_club_references
    def create
      @sy_club_reference = SyClubReference.new(sy_club_reference_params)
      if @sy_club_reference.save
        render json: @sy_club_reference
      else
        render json: @sy_club_reference.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /sy_club_references/1
    def update
      authorize @sy_club_reference
      if @sy_club_reference.update(sy_club_reference_params)
        render json: @sy_club_reference
      else
        render json: @sy_club_reference.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /sy_club_references/1
    def destroy
      sy_club_reference = @sy_club_reference.destroy
      render json: sy_club_reference
    end
  
    def locate_collection
      if params.has_key?("filter")
        @sy_club_references = ::Api::V1::SyClubReferencePolicy::Scope.new(current_user, SyClubReference).resolve(filtering_params)
      else
        @sy_club_references = policy_scope(SyClubReference)
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_sy_club_reference
        @sy_club_reference = SyClubReference.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def sy_club_reference_params
        params.require(:sy_club_reference).permit(:sy_club_id, :sadhak_profile_id, :name)
      end
  
      def filtering_params
        params.slice(:sy_club_id)
      end
  end
end
