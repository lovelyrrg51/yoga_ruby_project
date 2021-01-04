module Api::V1
  class CcavenueConfigsController < BaseController
    before_action :authenticate_user!
    before_action :set_ccavenue_config, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /ccavenue_configs
    def index
      @ccavenue_configs = CcavenueConfig.all
      render json: @ccavenue_configs
    end
  
    # GET /ccavenue_configs/1
    def show
    end
  
    # GET /ccavenue_configs/new
    def new
      @ccavenue_config = CcavenueConfig.new
    end
  
    # GET /ccavenue_configs/1/edit
    def edit
    end
  
    # POST /ccavenue_configs
    def create
      @ccavenue_config = CcavenueConfig.new(ccavenue_config_params)
      authorize @ccavenue_config
      if @ccavenue_config.save
        render json: @ccavenue_config
      else
        render json: @ccavenue_config.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /ccavenue_configs/1
    def update
      authorize @ccavenue_config
      if @ccavenue_config.update(ccavenue_config_params)
        render json: @ccavenue_config
      else
        render json: @ccavenue_config.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /ccavenue_configs/1
    def destroy
      cc_config = @ccavenue_config.destroy
      render json: cc_config
  
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ccavenue_config
        @ccavenue_config = CcavenueConfig.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def ccavenue_config_params
        params.require(:ccavenue_config).permit(:alias_name, :working_key, :merchant_id, :access_code, :payment_gateway_id, :country_id, :tax_amount)
      end
  end
end
