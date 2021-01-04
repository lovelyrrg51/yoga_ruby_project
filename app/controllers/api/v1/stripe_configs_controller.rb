module Api::V1
  class StripeConfigsController < BaseController
    before_action :set_stripe_config, only: [:show, :edit, :update, :destroy]
    before_action :authenticate_user!
    respond_to :json
  
    # GET /stripe_configs
    def index
      @stripe_configs = StripeConfig.all
      render json: @stripe_configs
    end
  
    # GET /stripe_configs/1
    def show
    end
  
    # GET /stripe_configs/new
    def new
      @stripe_config = StripeConfig.new
    end
  
    # GET /stripe_configs/1/edit
    def edit
    end
  
    # POST /stripe_configs
    def create
      @stripe_config = StripeConfig.new(stripe_config_params)
      authorize @stripe_config
      if @stripe_config.save
        render json: @stripe_config
      else
        render json: @stripe_config.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /stripe_configs/1
    def update
      authorize @stripe_config
      if @stripe_config.update(stripe_config_params)
        render json: @stripe_config
      else
        render json: @stripe_config.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /stripe_configs/1
    def destroy
      authorize @stripe_config
      sc = @stripe_config.destroy
      render json: sc
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_stripe_config
        @stripe_config = StripeConfig.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def stripe_config_params
        params.require(:stripe_config).permit(:publishable_key, :secret_key, :alias_name, :payment_gateway_id, :merchant_id, :country_id, :tax_amount)
      end
  end
end
