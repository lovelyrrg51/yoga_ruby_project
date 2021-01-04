module Api::V1
  class DigitalMarketplaceController < BaseController
    before_action :authenticate_user!
    layout "main_index.html.erb"
  
    def index
      @digital_assets = DigitalAsset.all
    end
  
    def buy
      @digital_asset = DigitalAsset.find(params[:id])
      @purchased_digital_asset = PurchasedDigitalAsset.new
    end
  
    def purchase
      d = DigitalAsset.find(params[:id])
      logger.info("\n\n\n***************#{d.valid_promo_code?(params[:promo_code_used])}**********************\n\n\n")
      if d.valid_promo_code?(params[:promo_code_used])
         @purchased_digital_asset = PurchasedDigitalAsset.new(:user_id => current_user.id, :digital_asset_id => d.id, promo_code_used => purchased_digital_asset_params[:promo_code_used])
      end
      respond_to do |format|
        if @purchased_digital_asset && @purchased_digital_asset.save
          format.html { redirect_to library_path, notice: '#{@purchased_digital_asset.digital_asset.asset_name} was successfully purchased.' }
          format.json { render action: 'buy', status: :created, location: @digital_asset }
        else
          format.html { redirect_to action: 'buy', id:params[:id] }
          format.json { render json: @digital_asset.errors, status: :unprocessable_entity }
        end
      end
    end
  
    private
  
    def purchased_digital_asset_params
      params.require(:purchased_digital_asset).permit! #(:PurchasedDigitalAsset)
    end
  end
end
