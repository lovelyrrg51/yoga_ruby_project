module Api::V1
  class PgSyPaypalConfigsController < BaseController
    before_action :authenticate_user!, :except => [:index]
    before_action :set_pg_sy_paypal_config, only: [:show, :edit, :update, :destroy]
    respond_to :json
    skip_before_action :verify_authenticity_token, :only => [:index]
  
    # GET /pg_sy_paypal_configs
    def index
      @pg_sy_paypal_configs = PgSyPaypalConfig.all
      render json: @pg_sy_paypal_configs
    end
  
    # GET /pg_sy_paypal_configs/1
    def show
    end
  
    # GET /pg_sy_paypal_configs/new
    def new
      @pg_sy_paypal_config = PgSyPaypalConfig.new
    end
  
    # GET /pg_sy_paypal_configs/1/edit
    def edit
    end
  
    # POST /pg_sy_paypal_configs
    def create
      @pg_sy_paypal_config = PgSyPaypalConfig.new(pg_sy_paypal_config_params)
      authorize @pg_sy_paypal_config
      if @pg_sy_paypal_config.save
        render json: @pg_sy_paypal_config
      else
        render json: @pg_sy_paypal_config.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /pg_sy_paypal_configs/1
    def update
      authorize @pg_sy_paypal_config
      if @pg_sy_paypal_config.update(pg_sy_paypal_config_params)
        render json: @pg_sy_paypal_config
      else
        render json: @pg_sy_paypal_config.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /pg_sy_paypal_configs/1
    def destroy
      authorize @pg_sy_paypal_config
      pg_paypal_config = @pg_sy_paypal_config.destroy
      render json: pg_paypal_config
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_pg_sy_paypal_config
        @pg_sy_paypal_config = PgSyPaypalConfig.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def pg_sy_paypal_config_params
        params.require(:pg_sy_paypal_config).permit(:username, :password, :signature, :country_id, :tax_amount, :alias_name, :publishable_key, :secret_key, :merchant_id, :payment_gateway_id)
      end
  end
end
