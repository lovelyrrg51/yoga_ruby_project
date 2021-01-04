module Api::V1
  class PgSywiretransferMerchantsController < BaseController
    before_action :set_pg_sywiretransfer_merchant, only: [:show, :edit, :update, :destroy]
    before_action :authenticate_user!
    respond_to :json
  
    # GET /pg_sywiretransfer_merchants
    def index
      @pg_sywiretransfer_merchants = policy_scope(PgSywiretransferMerchant)
      render json:  @pg_sywiretransfer_merchants
    end
  
    # GET /pg_sywiretransfer_merchants/1
    def show
    end
  
    # GET /pg_sywiretransfer_merchants/new
    def new
      @pg_sywiretransfer_merchant = PgSywiretransferMerchant.new
    end
  
    # GET /pg_sywiretransfer_merchants/1/edit
    def edit
    end
  
    # POST /pg_sywiretransfer_merchants
    def create
      @pg_sywiretransfer_merchant = PgSywiretransferMerchant.new(pg_sywiretransfer_merchant_params)
      authorize @pg_sywiretransfer_merchant
      if @pg_sywiretransfer_merchant.save
        render json:  @pg_sywiretransfer_merchant
      else
        render json: @pg_sywiretransfer_merchant.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /pg_sywiretransfer_merchants/1
    def update
      authorize @pg_sywiretransfer_merchant
      if @pg_sywiretransfer_merchant.update(pg_sywiretransfer_merchant_params)
        render json:  @pg_sywiretransfer_merchant
      else
        render json: @pg_sywiretransfer_merchant.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /pg_sywiretransfer_merchants/1
    def destroy
      authorize @pg_sywiretransfer_merchant
      pswtm = @pg_sywiretransfer_merchant.destroy
      render json: pswtm
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_pg_sywiretransfer_merchant
        @pg_sywiretransfer_merchant = PgSywiretransferMerchant.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def pg_sywiretransfer_merchant_params
        params.require(:pg_sywiretransfer_merchant).permit(:name, :domain, :email, :mobile, :email_enabled, :sms_enabled, :sms_limit, :public_key, :private_key)
      end
  end
end
