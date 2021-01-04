module Api::V1
  class DsProductsController < BaseController
    before_action :authenticate_user!
    before_action :set_ds_product, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /ds_products
    def index
      @ds_products = DsProduct.all
      render json: @ds_products
    end
  
    # GET /ds_products/1
    def show
    end
  
    # GET /ds_products/new
    def new
      @ds_product = DsProduct.new
    end
  
    # GET /ds_products/1/edit
    def edit
    end
  
    # POST /ds_products
    def create
      @ds_product = DsProduct.new(ds_product_params)
      if @ds_product.save
        render json: @ds_product
      else
        render json: @ds_product.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /ds_products/1
    def update
      if @ds_product.update(ds_product_params)
        render json: @ds_product
      else
        render json: @ds_product.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /ds_products/1
    def destroy
     dsp= @ds_product.destroy
     render json: dsp
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ds_product
        @ds_product = DsProduct.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def ds_product_params
        params.require(:ds_products).permit(:ds_asset_tag_id)
      end
  end
end
