module Api::V1
  class DsProductDetailsController < BaseController
    before_action :authenticate_user!
    before_action :set_ds_product_detail, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /ds_product_details
    def index
      @ds_product_details = DsProductDetail.all
      render json: @ds_product_details
    end
  
    # GET /ds_product_details/1
    def show
    end
  
    # GET /ds_product_details/new
    def new
      @ds_product_detail = DsProductDetail.new
    end
  
    # GET /ds_product_details/1/edit
    def edit
    end
  
    # POST /ds_product_details
    def create
      @ds_product_detail = DsProductDetail.new(ds_product_detail_params)
      if @ds_product_detail.save
        render json: @ds_product_detail
      else
        render json: @ds_product_detail.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /ds_product_details/1
    def update
      if @ds_product_detail.update(ds_product_detail_params)
        render json: @ds_product_detail
      else
        render json: @ds_product_detail.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /ds_product_details/1
    def destroy
      dpd = @ds_product_detail.destroy
      render json: dpd
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ds_product_detail
        @ds_product_detail = DsProductDetail.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def ds_product_detail_params
        params.require(:ds_product_detail).permit(:name, :description, :price, :availability, :video_url, :ds_product_id)
      end
  end
end
