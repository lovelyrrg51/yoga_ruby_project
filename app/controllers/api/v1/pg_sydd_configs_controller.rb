module Api::V1
  class PgSyddConfigsController < BaseController
    before_action :authenticate_user!
    before_action :set_pg_sydd_config, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /pg_sydd_configs
    def index
      @pg_sydd_configs = PgSyddConfig.all
      render json: @pg_sydd_configs
    end
  
    # GET /pg_sydd_configs/1
    # GET /pg_sydd_configs/1.json
    def show
    end
  
    # GET /pg_sydd_configs/new
    def new
      @pg_sydd_config = PgSyddConfig.new
    end
  
    # GET /pg_sydd_configs/1/edit
    def edit
    end
  
    # POST /pg_sydd_configs
    def create
      # @merchant = PgSyddMerchant.find(pg_sydd_config_params[:pg_sydd_merchant_id])
      @pg_sydd_config = PgSyddConfig.new(pg_sydd_config_params)
      authorize @pg_sydd_config
      # if @merchant.present?
      if @pg_sydd_config.save
        render json: @pg_sydd_config
      else
        render json: @pg_sydd_config.errors, status: :unprocessable_entity
      end
      # else
      #   render json: { errors: @pg_sydd_config.errors}, status: :unprocessable_entity
      # end
    end
  
    # PATCH/PUT /pg_sydd_configs/1
    def update
      authorize @pg_sydd_config
      if @pg_sydd_config.update(pg_sydd_config_params)
        render json: @pg_sydd_config
      else
        render json: @pg_sydd_config.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /pg_sydd_configs/1
    def destroy
      pgc = @pg_sydd_config.destroy
      render json: pgc
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_pg_sydd_config
        @pg_sydd_config = PgSyddConfig.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def pg_sydd_config_params
        params.require(:pg_sydd_config).permit(:public_key, :private_key, :payment_gateway_id, :alias_name, :country_id, :tax_amount)#, :pg_sydd_merchant_id)
      end
  end
end
