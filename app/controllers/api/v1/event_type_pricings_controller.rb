module Api::V1
  class EventTypePricingsController < BaseController
    before_action :set_event_type_pricing, only: [:show, :edit, :update, :destroy]
    respond_to :json
    # GET /event_type_pricings
    def index
      @event_type_pricings = EventTypePricing.includes(:event_type).all
      render json: @event_type_pricings
    end
  
    # GET /event_type_pricings/1
    def show
    end
  
    # GET /event_type_pricings/new
    def new
      @event_type_pricing = EventTypePricing.new
    end
  
    # GET /event_type_pricings/1/edit
    def edit
    end
  
    # POST /event_type_pricings
    def create
      @event_type_pricing = EventTypePricing.new(event_type_pricing_params)
  
      if @event_type_pricing.save
        render json: @event_type_pricing
      else
        render json: @event_type_pricing.errors, status: :unprocessable_entity
      end
  
    end
  
    # PATCH/PUT /event_type_pricings/1
    def update
      if @event_type_pricing.update(event_type_pricing_params)
        render json: @event_type_pricing
      else
        render json: @event_type_pricing.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /event_type_pricings/1
    def destroy
      type_price = @event_type_pricing.destroy
      render json: type_price
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_type_pricing
        @event_type_pricing = EventTypePricing.includes(:event_type).find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def event_type_pricing_params
        params.require(:event_type_pricing).permit(:name, :price, :tier_type, :event_type_id)
      end
  end
end
