module Api::V1
  class EventOrderLineItemsController < BaseController
    before_action :authenticate_user!, except: [:index, :show, :destroy]
    before_action :set_event_order_line_item, only: [:show, :edit, :update, :destroy]
    before_action :locate_collection, :only => :index
    skip_before_action :verify_authenticity_token, :only => [:destroy]
    respond_to :json
  
     # GET /event_types
    def index
  #     @event_order_line_items = policy_scope(EventOrderLineItem)
      render json: @event_order_line_items
    end
  
    # GET /event_types/1
    def show
  #     @event_order_line_item = EventOrderLineItem.find(params[:id])
      render json: @event_order_line_item
    end
  
    # GET /event_types/new
    def new
      @event_order_line_item = EventOrderLineItem.new
    end
  
    # GET /event_types/1/edit
    def edit
    end
  
    # POST /event_types
    def create
      @event_order_line_item = EventOrderLineItem.new(event_order_line_items_params)
      authorize @event_order_line_item
      if @event_order_line_item.save
        render json: @event_order_line_item
      else
        render json: @event_order_line_item.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /event_types/1
    def update
      authorize @event_order_line_item
      if @event_type.update(event_order_line_items_params)
        render json: @event_order_line_item
      else
        render json: @event_order_line_item.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /event_types/1
    def destroy
      if @event_order_line_item.destroy
        render json: @event_order_line_item
      else
        render json: @event_order_line_item.errors, status: :unprocessable_entity
      end
    end
  
    def locate_collection
      if (params.has_key?("filter"))
        @event_order_line_items = EventOrderLineItemPolicy::Scope.new(current_user, EventOrderLineItem.preloaded_data).resolve(filtering_params)
      else
        @event_order_line_item = policy_scope(EventOrderLineItem.preloaded_data)
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_order_line_item
       @event_order_line_item = EventOrderLineItem.preloaded_data.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def event_order_line_items_params
        params.require(:event_order_line_item).permit!
      end
  
      def filtering_params
        params.slice(:event_order_id)
      end
  end
end
