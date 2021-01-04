module Api::V1
  class PgSyddMerchantsController < BaseController
  #   before_action :authenticate_user!
    require "base64"
    before_action :authenticate_user!
    before_action :set_pg_sydd_merchant, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /pg_sydd_merchants
    def index
      @pg_sydd_merchants = policy_scope(PgSyddMerchant)
      render json:  @pg_sydd_merchants
    end
  
    # GET /pg_sydd_merchants/1
    def show
  #     @pg_sydd_merchant = PgSyddMerchant.find(params[:id])
  #     private_key = @pg_sydd_merchant.private_key
  # #     private_key = "269638491376543219"
  #     pg_sy_dd_merchant_json = @pg_sydd_merchant.to_json
  #     enc_pg_sydd_merchant = Base64.encode64(pg_sy_dd_merchant_json)
  #     aes_enc_pg_merchants = Crypto.new.encrypt256(enc_pg_sydd_merchant, private_key)
  #     re_en_base = Base64.encode64(aes_enc_pg_merchants)
  #     render json: {pg_sydd_json: pg_sy_dd_merchant_json, en64: enc_pg_sydd_merchant, enAES: aes_enc_pg_merchants, re_eb_base: re_en_base}
  #     return false
    end
  
    # GET /pg_sydd_merchants/new
    def new
      @pg_sydd_merchant = PgSyddMerchant.new
    end
  
    # GET /pg_sydd_merchants/1/edit
    def edit
    end
  
    # POST /pg_sydd_merchants
    def create
      @pg_sydd_merchant = PgSyddMerchant.new(pg_sydd_merchant_params)
      authorize @pg_sydd_merchant
      if @pg_sydd_merchant.save
        render json:  @pg_sydd_merchant
      else
        render json: @pg_sydd_merchant.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /pg_sydd_merchants/1
    def update
      authorize @pg_sydd_merchant
      if @pg_sydd_merchant.update(pg_sydd_merchant_params)
        render json:  @pg_sydd_merchant
      else
        render json: @pg_sydd_merchant.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /pg_sydd_merchants/1
    def destroy
      authorize @pg_sydd_merchant
      @pg_sydd_merchant.destroy
      respond_to do |format|
        format.html { redirect_to pg_sydd_merchants_url, notice: 'Pg sydd merchant was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_pg_sydd_merchant
        @pg_sydd_merchant = PgSyddMerchant.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def pg_sydd_merchant_params
        params.require(:pg_sydd_merchant).permit(:name, :domain, :email, :mobile, :email_enabled, :sms_enabled, :sms_limit, :public_key, :private_key)
      end
  end
end
