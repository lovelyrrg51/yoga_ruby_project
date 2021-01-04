module Api::V1
  class EventCostEstimationsController < BaseController
    before_action :authenticate_user!
    before_action :set_event_cost_estimation, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /event_cost_estimations
    def index
      @event_cost_estimations = policy_scope(EventCostEstimation)
      render json: @event_cost_estimations
    end
  
    # GET /event_cost_estimations/1
    def show
      render json: @event_cost_estimation
    end
  
    # GET /event_cost_estimations/new
    def new
      @event_cost_estimation = EventCostEstimation.new
    end
  
    # GET /event_cost_estimations/1/edit
    def edit
    end
  
    # POST /event_cost_estimations
    def create
      @event_cost_estimation = EventCostEstimation.new(event_cost_estimation_params)
      authorize @event_cost_estimation
      if @event_cost_estimation.save
        render json: @event_cost_estimation
      else
        render json: @event_cost_estimation.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /event_cost_estimations/1
    def update
      authorize @event_cost_estimation
      if @event_cost_estimation.update(event_cost_estimation_params)
        render json: @event_cost_estimation
      else
        render json: @event_cost_estimation.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /event_cost_estimations/1
    def destroy
      authorize @event_cost_estimation
      eca = @event_cost_estimation.destroy
      render json: eca
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_cost_estimation
        @event_cost_estimation = EventCostEstimation.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def event_cost_estimation_params
        params.require(:event_cost_estimation).permit(:name, :budget, :event_id)
      end
  end
end
