module Api::V1
  class EventCancellationPlanItemsController < BaseController
    before_action :set_event_cancellation_plan_item, only: [:show, :edit, :update, :destroy]
    before_action :locate_collection, :only => :index
    before_action :authenticate_user!, except: [:index]
    skip_before_action :verify_authenticity_token, :only => []
    respond_to :json
  
    # GET /event_cancellation_plan_items
    def index
      render json: @event_cancellation_plan_items
    end
  
    # GET /event_cancellation_plan_items/1
    def show
      authorize @event_cancellation_plan_item
      render json: @event_cancellation_plan_item
    end
  
    # GET /event_cancellation_plan_items/new
    def new
      render json: {}
    end
  
    # GET /event_cancellation_plan_items/1/edit
    def edit
      render json: {}
    end
  
    # POST /event_cancellation_plan_items
    def create
      @event_cancellation_plan_item = EventCancellationPlanItem.new(event_cancellation_plan_item_params)
      authorize @event_cancellation_plan_item
      if @event_cancellation_plan_item.save
        render json: @event_cancellation_plan_item
      else
        render json: @event_cancellation_plan_item.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /event_cancellation_plan_items/1
    def update
      authorize @event_cancellation_plan_item
      if @event_cancellation_plan_item.update(event_cancellation_plan_item_params)
        render json: @event_cancellation_plan_item
      else
        render json: @event_cancellation_plan_item.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # DELETE /event_cancellation_plan_items/1
    def destroy
      authorize @event_cancellation_plan_item
      if @event_cancellation_plan_item.update(is_deleted: true)
        render json: @event_cancellation_plan_item
      else
        render json: @event_cancellation_plan_item.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    def locate_collection
      if params.has_key?("filter")
        @event_cancellation_plan_items = EventCancellationPlanItemPolicy::Scope.new(current_user, EventCancellationPlanItem.preloaded_data).resolve(filtering_params)
      else
        @event_cancellation_plan_items = policy_scope(EventCancellationPlanItem.preloaded_data)
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_cancellation_plan_item
        @event_cancellation_plan_item = EventCancellationPlanItem.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def event_cancellation_plan_item_params
        params.require(:event_cancellation_plan_item).permit(:event_cancellation_plan_id, :days_before, :amount, :amount_type)
      end
  
      def filtering_params
        params.slice(:event_cancellation_plan_id, :days_before)
      end
  end
end
