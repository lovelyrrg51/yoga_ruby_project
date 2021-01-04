module Api::V1
  class PgSyRazorpayConfigsController < BaseController
    before_action :set_pg_sy_razorpay_config, only: [:show, :edit, :update, :destroy]
    before_action :authenticate_user!
    respond_to :json
  
    # GET /pg_sy_razorpay_configs
    def index
      @pg_sy_razorpay_configs = PgSyRazorpayConfig.all
      render json: @pg_sy_razorpay_configs
    end
  
    # GET /pg_sy_razorpay_configs/1
    def show
      authorize @pg_sy_razorpay_config
      render json: @pg_sy_razorpay_config
    end
  
    # GET /pg_sy_razorpay_configs/new
    def new
      @pg_sy_razorpay_config = PgSyRazorpayConfig.new
    end
  
    # GET /pg_sy_razorpay_configs/1/edit
    def edit
    end
  
    # POST /pg_sy_razorpay_configs
    def create
      @pg_sy_razorpay_config = PgSyRazorpayConfig.new(pg_sy_razorpay_config_params)
      authorize @pg_sy_razorpay_config
      if @pg_sy_razorpay_config.save
        render json: @pg_sy_razorpay_config
      else
        render json: @pg_sy_razorpay_config.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /pg_sy_razorpay_configs/1
    def update
      authorize @pg_sy_razorpay_config
      if @pg_sy_razorpay_config.update(pg_sy_razorpay_config_params)
        render json: @pg_sy_razorpay_config
      else
        render json: @pg_sy_razorpay_config.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /pg_sy_razorpay_configs/1
    # DELETE /pg_sy_razorpay_configs/1.json
    def destroy
      authorize @pg_sy_razorpay_config
      rpc = @pg_sy_razorpay_config.destroy
      render json: rpc
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_pg_sy_razorpay_config
        @pg_sy_razorpay_config = PgSyRazorpayConfig.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def pg_sy_razorpay_config_params
        params.require(:pg_sy_razorpay_config).permit(:publishable_key, :secret_key, :alias_name, :merchant_id, :country_id, :tax_amount, :payment_gateway_id)
      end
  end
end
