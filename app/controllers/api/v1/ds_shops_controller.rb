module Api::V1
  class DsShopsController < BaseController
    before_action :authenticate_user!
    before_action :set_ds_shop, only: [:show, :edit, :update, :destroy]
    respond_to :json

    # GET /ds_shops
    def index
      @ds_shops = DsShop.all
      render json: @ds_shops
    end

    # GET /ds_shops/1
    def show
    end

    # GET /ds_shops/new
    def new
      @ds_shop = DsShop.new
    end

    # GET /ds_shops/1/edit
    def edit
    end

    # POST /ds_shops
    def create
      @ds_shop = DsShop.new(ds_shop_params)
      if @ds_shop.save
        render json: @ds_shop
      else
        render json: @ds_shop.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /ds_shops/1
    def update
      if @ds_shop.update(ds_shop_params)
        render json: @ds_shop
      else
        render json: @ds_shop.errors, status: :unprocessable_entity
      end
    end

    # DELETE /ds_shops/1
    def destroy
      ds_shop = @ds_shop.destroy
      render json: ds_ahop
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ds_shop
        @ds_shop = DsShop.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def ds_shop_params
        params.require(:ds_shop).permit(:name, :description, :event_id)
      end
  end
end
