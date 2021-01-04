module Api::V1
  class EventAwarenessTypesController < BaseController
    before_action :authenticate_user!
    before_action :set_event_awareness_type, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /event_awareness_types
    def index
      @event_awareness_types = policy_scope(EventAwarenessType)
      render json: @event_awareness_types
    end
  
    # GET /event_awareness_types/1
    def show
      render json: @event_awareness_type
    end
  
    # GET /event_awareness_types/new
    def new
      @event_awareness_type = EventAwarenessType.new
    end
  
    # GET /event_awareness_types/1/edit
    def edit
    end
  
    # POST /event_awareness_types
    def create
      @event_awareness_type = EventAwarenessType.new(event_awareness_type_params)
      authorize @event_awareness_type
      if @event_awareness_type.save
          render json: @event_awareness_type
      else
          render json: @event_awareness_type.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /event_awareness_types/1
    def update
      authorize @event_awareness_type
      if @event_awareness_type.update(event_awareness_type_params)
        render json: @event_awareness_type
      else
        render json: @event_awareness_type.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /event_awareness_types/1
    def destroy
      authorize @event_awareness_type
      ea = @event_awareness_type.destroy
      render json: ea
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_awareness_type
        @event_awareness_type = EventAwarenessType.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def event_awareness_type_params
        params.require(:event_awareness_type).permit(:name, :code)
      end
  end
end
