module Api::V1
  class BhandaraDetailsController < BaseController
    before_action :authenticate_user!
    before_action :set_bhandara_detail, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /bhandara_details
    def index
      @bhandara_details = policy_scope(BhandaraDetail)
      render json: @bhandara_details
    end
  
    # GET /bhandara_details/1
    def show
      render json: @bhandara_detail
    end
  
    # GET /bhandara_details/new
    def new
      @bhandara_detail = BhandaraDetail.new
    end
  
    # GET /bhandara_details/1/edit
    def edit
    end
  
    # POST /bhandara_details
    def create
      @bhandara_detail = BhandaraDetail.new(bhandara_detail_params)
      authorize @bhandara_detail
      if @bhandara_detail.save
        render json: @bhandara_detail
      else
        render json: @bhandara_detail.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /bhandara_details/1
    def update
      authorize @bhandara_detail
      if @bhandara_detail.update(bhandara_detail_params)
        render json: @bhandara_detail
      else
        render json: @bhandara_detail.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /bhandara_details/1
    def destroy
      authorize @bhandara_detail
      bah = @bhandara_detail.destroy
      render json: bah
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_bhandara_detail
        @bhandara_detail = BhandaraDetail.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def bhandara_detail_params
        params.require(:bhandara_detail).permit(:budget, :event_id)
      end
  end
end
