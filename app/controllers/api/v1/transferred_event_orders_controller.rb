module Api::V1
  class TransferredEventOrdersController < BaseController
    before_action :authenticate_user!
    before_action :set_transferred_event_order, only: [:show, :edit, :update, :destroy]
    respond_to :json
    # GET /transferred_event_orders
    # GET /transferred_event_orders.json
    def index
      @transferred_event_orders = TransferredEventOrder.all
    end
  
    # GET /transferred_event_orders/1
    # GET /transferred_event_orders/1.json
    def show
    end
  
    # GET /transferred_event_orders/new
    def new
      @transferred_event_order = TransferredEventOrder.new
    end
  
    # GET /transferred_event_orders/1/edit
    def edit
    end
  
    # POST /transferred_event_orders
    # POST /transferred_event_orders.json
    def create(transferred_order_params = nil)
      if transferred_order_params != nil
        transferred_event_order_params = transferred_order_params
        teo = TransferredEventOrder.create(transferred_event_order_params)
        return teo
      else
        @transferred_event_order = TransferredEventOrder.new(transferred_event_order_params)
        if @transferred_event_order.save
          render json: @transferred_event_order
        else
          render json: @transferred_event_order.errors, status: :unprocessable_entity
        end
      end
    end
  
    # PATCH/PUT /transferred_event_orders/1
    # PATCH/PUT /transferred_event_orders/1.json
    def update
        if @transferred_event_order.update(transferred_event_order_params)
          format.html { redirect_to @transferred_event_order, notice: 'Transferred event order was successfully updated.' }
          format.json { render :show, status: :ok, location: @transferred_event_order }
        else
          format.html { render :edit }
          format.json { render json: @transferred_event_order.errors, status: :unprocessable_entity }
        end
    end
  
    # DELETE /transferred_event_orders/1
    # DELETE /transferred_event_orders/1.json
    def destroy
      @transferred_event_order.destroy
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_transferred_event_order
        @transferred_event_order = TransferredEventOrder.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def transferred_event_order_params
        params.require(:transferred_event_order).permit(:child_event_order_id)
      end
  end
end
