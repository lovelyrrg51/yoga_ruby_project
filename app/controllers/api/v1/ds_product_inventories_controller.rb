module Api::V1
  class DsProductInventoriesController < BaseController
    before_action :authenticate_user!
    before_action :set_ds_product_inventory, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /ds_product_inventories
    def index
      @ds_product_inventories = DsProductInventory.all
      render json: @ds_product_inventories
    end
  
    # GET /ds_product_inventories/1
    def show
    end
  
    # GET /ds_product_inventories/new
    def new
      @ds_product_inventory = DsProductInventory.new
    end
  
    # GET /ds_product_inventories/1/edit
    def edit
    end
  
    # POST /ds_product_inventories
    def create
      @ds_product_inventory = DsProductInventory.new(ds_product_inventory_params)
      if @ds_product_inventory.save
        render json: @ds_product_inventory
      else
        render json: @ds_product_inventory.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /ds_product_inventories/1
    def update
      if @ds_product_inventory.update(ds_product_inventory_params)
        render json: @ds_product_inventory
      else
        render json: @ds_product_inventory.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /ds_product_inventories/1
    def destroy
      dspi = @ds_product_inventory.destroy
      render json: dspi
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ds_product_inventory
        @ds_product_inventory = DsProductInventory.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def ds_product_inventory_params
        params.require(:ds_product_inventory).permit(:ds_product_id, :ds_shop_id, :quantity)
      end
  end
end
