module Api::V1
  class PgSyPayfastConfigsController < BaseController
    before_action :authenticate_user!, except: []
    before_action :set_pg_sy_payfast_config, only: [:show, :edit, :update, :destroy]
    skip_before_action :verify_authenticity_token, :only => []
    respond_to :json
  
    # GET /pg_sy_payfast_configs
    def index
      @pg_sy_payfast_configs = PgSyPayfastConfig.all
      render json: @pg_sy_payfast_configs
    end
  
    # GET /pg_sy_payfast_configs/1
    def show
      authorize @pg_sy_payfast_config
      render json: @pg_sy_payfast_config
    end
  
    # GET /pg_sy_payfast_configs/new
    def new
      render json: {}
    end
  
    # GET /pg_sy_payfast_configs/1/edit
    def edit
    end
  
    # POST /pg_sy_payfast_configs
    def create
      @pg_sy_payfast_config = PgSyPayfastConfig.new(pg_sy_payfast_config_params)
      authorize @pg_sy_payfast_config
      if @pg_sy_payfast_config.save
        render json: @pg_sy_payfast_config
      else
        render json: @pg_sy_payfast_config.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /pg_sy_payfast_configs/1
    def update
      authorize @pg_sy_payfast_config
      if @pg_sy_payfast_config.update(pg_sy_payfast_config_params)
        render json: @pg_sy_payfast_config
      else
        render json: @pg_sy_payfast_config.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # DELETE /pg_sy_payfast_configs/1
    def destroy
      authorize @pg_sy_payfast_config
      if @pg_sy_payfast_config.update(is_deleted: true)
        render json: @pg_sy_payfast_config
      else
        render json: @pg_sy_payfast_config.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_pg_sy_payfast_config
        @pg_sy_payfast_config = PgSyPayfastConfig.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def pg_sy_payfast_config_params
        params.require(:pg_sy_payfast_config).permit(:user_name, :alias_name, :merchant_id, :merchant_key, :payment_gateway_id, :country_id, :tax_amount)
      end
  end
end
