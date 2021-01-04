module Api::V1
  class EventCancellationPlansController < BaseController
    before_action :set_event_cancellation_plan, only: [:show, :edit, :update, :destroy]
    before_action :authenticate_user!, except: []
    before_action :locate_collection, :only => :index
    skip_before_action :verify_authenticity_token, :only => []
    respond_to :json
  
    # GET /event_cancellation_plans
    def index
      render json: @event_cancellation_plans
    end
  
    # GET /event_cancellation_plans/1
    def show
      authorize @event_cancellation_plan
      render json: @event_cancellation_plan
    end
  
    # GET /event_cancellation_plans/new
    def new
      render json: {}
    end
  
    # GET /event_cancellation_plans/1/edit
    def edit
      render json: {}
    end
  
    # POST /event_cancellation_plans
    def create
      @event_cancellation_plan = EventCancellationPlan.new(event_cancellation_plan_params)
      authorize @event_cancellation_plan
      if @event_cancellation_plan.save
        render json: @event_cancellation_plan
      else
        render json: @event_cancellation_plan.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /event_cancellation_plans/1
    def update
      authorize @event_cancellation_plan
      if @event_cancellation_plan.update(event_cancellation_plan_params)
        render json: @event_cancellation_plan
      else
        render json: @event_cancellation_plan.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # DELETE /event_cancellation_plans/1
    def destroy
      authorize @event_cancellation_plan
      if @event_cancellation_plan.update(is_deleted: true)
        render json: @event_cancellation_plan
      else
        render json: @event_cancellation_plan.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    def locate_collection
      if params.has_key?("filter")
        @event_cancellation_plans = EventCancellationPlanPolicy::Scope.new(current_user, EventCancellationPlan.preloaded_data).resolve(filtering_params)
      else
        @event_cancellation_plans = policy_scope(EventCancellationPlan.preloaded_data)
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_cancellation_plan
        @event_cancellation_plan = EventCancellationPlan.preloaded_data.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def event_cancellation_plan_params
        params.require(:event_cancellation_plan).permit(:name)
      end
  
      def filtering_params
        {}
      end
  end
end
