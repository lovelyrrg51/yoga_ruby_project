module Api::V1
  class PurchasedDigitalAssetsController < BaseController
     before_action :authenticate_user!
    respond_to :json
  #   layout "main_index.html.erb"
  
    def index
    	@purchased_digital_assets = PurchasedDigitalAsset.where(:user_id => current_user.id)
      render json: @purchased_digital_assets
    end
  
    def show
    	@purchased_digital_asset = PurchasedDigitalAsset.find_by_digital_asset_id(params[:id])
    	if @purchased_digital_asset.blank? || (@purchased_digital_asset.user_id != current_user.id)
    		redirect_to :action => :unauthorized
    	end
    end
  
    def create
      #jay: need to add pundit policy here. for now now creation allowed directly. it happens implictly thought payment success
  
  #     if PurchasedDigitalAsset.exists?(:digital_asset_id => params[:id], :user_id => current_user.id) == false
  #       @purchased_digital_asset = PurchasedDigitalAsset.new
  #       @purchased_digital_asset.digital_asset_id = params[:id]
  #       @purchased_digital_asset.user_id = current_user.id
  #       @purchased_digital_asset.save
  #     end
  #     render json: @purchased_digital_asset
    end
  
    def unauthorized
  
    end
  end
end
