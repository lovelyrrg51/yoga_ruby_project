module Api::V1
  class DsInventoryRequestsController < BaseController
    before_action :authenticate_user!
    before_action :set_ds_inventory_request, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /ds_inventory_requests
    def index
      @ds_inventory_requests = DsInventoryRequest.all
      render json: @ds_inventory_requests
    end
  
    # GET /ds_inventory_requests/1
    def show
    end
  
    # GET /ds_inventory_requests/new
    def new
      @ds_inventory_request = DsInventoryRequest.new
    end
  
    # GET /ds_inventory_requests/1/edit
    def edit
    end
  
    # POST /ds_inventory_requests
    def create
      @ds_inventory_request = DsInventoryRequest.new(ds_inventory_request_params)
      if @ds_inventory_request.save
        render json: @ds_inventory_request
      else
        render json: @ds_inventory_request.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /ds_inventory_requests/1
    def update
      if @ds_inventory_request.update(ds_inventory_request_params)
        render json: @ds_inventory_requests
      else
        render json: @ds_inventory_request.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /ds_inventory_requests/1
    def destroy
      ds_ir =  @ds_inventory_request.destroy
      render json: ds_ir
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ds_inventory_request
        @ds_inventory_request = DsInventoryRequest.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def ds_inventory_request_params
        params.require(:ds_inventory_request).permit(:quantity, :ds_product_id, :ds_product_inventory_request_id, :ds_asset_tag_id)
      end
  end
end
