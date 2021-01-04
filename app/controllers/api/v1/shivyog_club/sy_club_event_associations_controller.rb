module Api::V1::ShivyogClub
  class SyClubEventAssociationsController < ::Api::V1::BaseController
    before_action :authenticate_user!, except: [:index, :create]
    before_action :set_sy_club_event_association, only: [:show, :edit, :update, :destroy]
    respond_to :json
    skip_before_action :verify_authenticity_token, :only => [:index, :create]
  
    # GET /sy_club_event_associations
    def index
      @sy_club_event_associations = SyClubEventAssociation.all
      render json: @sy_club_event_associations
    end
  
    # GET /sy_club_event_associations/1
    def show
    end
  
    # GET /sy_club_event_associations/new
    def new
      @sy_club_event_association = SyClubEventAssociation.new
    end
  
    # GET /sy_club_event_associations/1/edit
    def edit
    end
  
    # POST /sy_club_event_associations
    def create
      @sy_club_event_association = SyClubEventAssociation.new(sy_club_event_association_params)
      if @sy_club_event_association.save
       render json: @sy_club_event_association
      else
        render json: @sy_club_event_association.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /sy_club_event_associations/1
    def update
      if @sy_club_event_association.update(sy_club_event_association_params)
        render json: @sy_club_event_association
      else
        render json: @sy_club_event_association.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /sy_club_event_associations/1
    def destroy
      sy_ea = @sy_club_event_association.destroy
      render json: sy_ea
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_sy_club_event_association
        @sy_club_event_association = SyClubEventAssociation.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def sy_club_event_association_params
        params.require(:sy_club_event_association).permit(:event_id, :sy_club_id)
      end
  end
end
