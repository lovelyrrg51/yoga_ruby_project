module Api::V1
  class DsProductInventoryRequestsController < BaseController
    before_action :authenticate_user!
    before_action :set_ds_product_inventory_request, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /ds_product_inventory_requests
    def index
      @ds_product_inventory_requests = DsProductInventoryRequest.all
      render json: @ds_product_inventory_requests
    end
  
    # GET /ds_product_inventory_requests/1
    def show
    end
  
    # GET /ds_product_inventory_requests/new
    def new
      @ds_product_inventory_request = DsProductInventoryRequest.new
    end
  
    # GET /ds_product_inventory_requests/1/edit
    def edit
    end
  
    # POST /ds_product_inventory_requests
    def create
      @ds_product_inventory_request = DsProductInventoryRequest.new(ds_product_inventory_request_params)
      if @ds_product_inventory_request.save
        render json: @ds_product_inventory_request
      else
        render json: @ds_product_inventory_request.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /ds_product_inventory_requests/1
    def update
      if @ds_product_inventory_request.update(ds_product_inventory_request_params)
        render json: @ds_product_inventory_request
      else
        render json: @ds_product_inventory_request.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /ds_product_inventory_requests/1
    def destroy
      ds_pi_r = @ds_product_inventory_request.destroy
  
      render json: ds_pi_r
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ds_product_inventory_request
        @ds_product_inventory_request = DsProductInventoryRequest.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def ds_product_inventory_request_params
        params.require(:ds_product_inventory_request).permit(:ds_shop_id, :status)
      end
  end
end
