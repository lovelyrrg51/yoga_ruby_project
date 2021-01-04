module Api::V1
  class EventSponsorsController < BaseController
    before_action :authenticate_user!
    before_action :locate_collection, :only => :index
    before_action :set_event_sponsor, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /event_sponsors
    def index
  #     @event_sponsors = EventSponsor.all
      render json: @event_sponsors
    end
  
    # GET /event_sponsors/1
    def show
    end
  
    # GET /event_sponsors/new
    def new
      @event_sponsor = EventSponsor.new
    end
  
    # GET /event_sponsors/1/edit
    def edit
    end
  
    # POST /event_sponsors
    def create
      @event_sponsor = EventSponsor.new(event_sponsor_params)
      if @event_sponsor.save
        render json: @event_sponsor
      else
        render json: @event_sponsor.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /event_sponsors/1
    def update
      if @event_sponsor.update(event_sponsor_params)
        render json: @event_sponsor
      else
        render json: @event_sponsor.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /event_sponsors/1
    def destroy
      ev_spr = @event_sponsor.destroy
      render json: ev_spr
    end
  
     def locate_collection
      if (params.has_key?("filter"))
        @event_sponsors = EventSponsorPolicy::Scope.new(current_user, EventSponsor).resolve(filtering_params)
      else
        @event_sponsors = policy_scope(EventSponsor)
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_sponsor
        @event_sponsor = EventSponsor.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def event_sponsor_params
        params.require(:event_sponsor).permit(:sadhak_profile_id, :event_id, :remarks)
      end
  
      def filtering_params
        params.slice(:event_id)
      end
  end
end
