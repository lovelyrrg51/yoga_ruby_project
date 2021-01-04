module Api::V1
  class BhandaraItemsController < BaseController
    before_action :authenticate_user!
    before_action :set_bhandara_item, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /bhandara_items
    def index
      @bhandara_items = BhandaraItem.all
      render json: @bhandara_items
    end
  
    # GET /bhandara_items/1
    def show
      render json: @bhandara_item
    end
  
    # GET /bhandara_items/new
    def new
      @bhandara_item = BhandaraItem.new
    end
  
    # GET /bhandara_items/1/edit
    def edit
    end
  
    # POST /bhandara_items
    def create
      @bhandara_item = BhandaraItem.new(bhandara_item_params)
      authorize @bhandara_item
      if @bhandara_item.save
        render json: @bahndara_item
      else
        render json: @bhandara_item.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /bhandara_items/1
    def update
  #     authorize @bhandara_item
      if @bhandara_item.update(bhandara_item_params)
        render json: @bhandara_item
      else
        render json: @bhandara_item.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /bhandara_items/1
    def destroy
      authorize @bhandara_item
      bd = @bhandara_item.destroy
      render json: bd
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_bhandara_item
        @bhandara_item = BhandaraItem.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def bhandara_item_params
        params.require(:bhandara_item).permit(:day, :item_name, :bhandara_detail_id, )
      end
  end
end
