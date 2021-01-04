module Api::V1
  class CannonicalEventsController < BaseController
    before_action :authenticate_user!, :except => [:index, :show]
    before_action :set_cannonical_event, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /cannonical_events
    def index
      @cannonical_events = policy_scope(CannonicalEvent).includes(:prerequisite_cannonical_events, :digital_assets)
      render json: @cannonical_events
    end
  
    # GET /cannonical_events/1
    def show
      render json: @cannonical_event
    end
  
    # GET /cannonical_events/new
    def new
      @cannonical_event = CannonicalEvent.new
    end
  
    # GET /cannonical_events/1/edit
    def edit
    end
  
    # POST /cannonical_events
    def create
      @cannonical_event = CannonicalEvent.new(cannonical_event_params)
      authorize @cannonical_event
      if @cannonical_event.save
        render json: @cannonical_event
      else
        render json: @cannonical_event.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /cannonical_events/1
    def update
      authorize @cannonical_event
      if @cannonical_event.update(cannonical_event_params)
        render json: @cannonical_event
      else
        render json: @cannonical_event.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /cannonical_events/1
    def destroy
      authorize @cannonical_event
      res = @cannonical_event.destroy
      render json: res
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_cannonical_event
        @cannonical_event = CannonicalEvent.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def cannonical_event_params
        params.require(:cannonical_event).permit!
      end
  end
end
