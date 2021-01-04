module Api::V1::ShivyogClub
  class SyClubEventTypeAssociationsController < ::Api::V1::BaseController
    before_action :authenticate_user!, except: [:index]
    before_action :set_sy_club_event_type_association, only: [:show, :edit, :update, :destroy]
    before_action :locate_collection, :only => :index
     skip_before_action :verify_authenticity_token, :only => [:index]
    respond_to :json
  
    # GET /sy_club_event_type_associations
    def index
      # @sy_club_event_type_associations = SyClubEventTypeAssociation.all
      render json: @sy_club_event_type_associations
    end
  
    # GET /sy_club_event_type_associations/1
    def show
    end
  
    # GET /sy_club_event_type_associations/new
    def new
      @sy_club_event_type_association = SyClubEventTypeAssociation.new
    end
  
    # GET /sy_club_event_type_associations/1/edit
    def edit
    end
  
    # POST /sy_club_event_type_associations
    def create
      @sy_club_event_type_association = SyClubEventTypeAssociation.new(sy_club_event_type_association_params)
      if @sy_club_event_type_association.save
        render json: @sy_club_event_type_association
      else
        render json: @sy_club_event_type_association.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /sy_club_event_type_associations/1
    def update
      if @sy_club_event_type_association.update(sy_club_event_type_association_params)
        render json: @sy_club_event_type_association
      else
       render json: @sy_club_event_type_association.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /sy_club_event_type_associations/1
    def destroy
      sy_club_et_association = @sy_club_event_type_association.destroy
      render json: sy_club_et_association
    end
  
    def locate_collection
      if params.has_key?("filter")
        @sy_club_event_type_associations = ::Api::V1::SyClubEventTypeAssociationPolicy::Scope.new(current_user, SyClubEventTypeAssociation).resolve(filtering_params)
      else
        @sy_club_event_type_associations = policy_scope(SyClubEventTypeAssociation)
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_sy_club_event_type_association
        @sy_club_event_type_association = SyClubEventTypeAssociation.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def sy_club_event_type_association_params
        params.require(:sy_club_event_type_association).permit(:sy_club_id, :event_type_id, :status)
      end
  
      def filtering_params
        params.slice(:sy_club_id)
      end
  end
end
