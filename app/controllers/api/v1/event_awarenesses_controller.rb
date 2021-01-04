module Api::V1
  class EventAwarenessesController < BaseController
    before_action :authenticate_user!
    before_action :set_event_awareness, only: [:show, :edit, :update, :destroy]
    respond_to :json
    # GET /event_awarenesses
    def index
      @event_awarenesses = policy_scope(EventAwareness)
      render json: @event_awarenesses
    end
  
    # GET /event_awarenesses/1
    def show
      render json: @event_awareness
    end
  
    # GET /event_awarenesses/new
    def new
      @event_awareness = EventAwareness.new
    end
  
    # GET /event_awarenesses/1/edit
    def edit
    end
  
    # POST /event_awarenesses
    def create
      @event_awareness = EventAwareness.new(event_awareness_params)
      authorize @event_awareness
      if @event_awareness.save
        render json: @event_awareness
      else
        render json: @event_awareness.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /event_awarenesses/1
    def update
      authorize @event_awareness
      if @event_awareness.update(event_awareness_params)
        render json: @event_awareness
      else
        render json: @event_awareness.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /event_awarenesses/1
    def destroy
      authorize @event_awareness
      ea =  @event_awareness.destroy
      render json: ea
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_awareness
        @event_awareness = EventAwareness.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def event_awareness_params
        params.require(:event_awareness).permit(:event_awareness_type_id, :event_id, :budget, :event_awareness_type_name)
      end
  end
end
