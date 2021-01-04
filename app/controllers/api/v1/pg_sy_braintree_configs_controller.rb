module Api::V1
  class PgSyBraintreeConfigsController < BaseController
    before_action :set_pg_sy_braintree_config, only: [:show, :edit, :update, :destroy]
  
  
    # GET /pg_sy_braintree_configs
    def index
      @pg_sy_braintree_configs = PgSyBraintreeConfig.all
      render json: @pg_sy_braintree_configs
    end
  
    # GET /pg_sy_braintree_configs/1
    def show
      authorize @pg_sy_braintree_config
      render json: @pg_sy_braintree_config
    end
  
    # GET /pg_sy_braintree_configs/new
    def new
      @pg_sy_braintree_config = PgSyBraintreeConfig.new
    end
  
    # GET /pg_sy_braintree_configs/1/edit
    def edit
    end
  
    # POST /pg_sy_braintree_configs
    def create
      @pg_sy_braintree_config = PgSyBraintreeConfig.new(pg_sy_braintree_config_params)
      authorize @pg_sy_braintree_config
      if @pg_sy_braintree_config.save
        render json: @pg_sy_braintree_config
      else
        render json: @pg_sy_braintree_config.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /pg_sy_braintree_configs/1
    def update
      authorize @pg_sy_braintree_config
      if @pg_sy_braintree_config.update(pg_sy_braintree_config_params)
        render json: @pg_sy_braintree_config
      else
        render json: @pg_sy_braintree_config.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /pg_sy_braintree_configs/1
    def destroy
      authorize @pg_sy_braintree_config
      btc = @pg_sy_braintree_config.destroy
      render json: btc
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_pg_sy_braintree_config
        @pg_sy_braintree_config = PgSyBraintreeConfig.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def pg_sy_braintree_config_params
        params.require(:pg_sy_braintree_config).permit(:publishable_key, :secret_key, :alias_name, :merchant_id, :country_id, :tax_amount, :payment_gateway_id)
      end
  end
end
