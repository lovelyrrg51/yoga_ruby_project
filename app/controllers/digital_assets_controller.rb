class DigitalAssetsController < ApplicationController
	before_action :set_collection, only: [:index, :edit, :update, :create]
	before_action :set_digital_asset, only: [:edit, :update, :destroy]
	before_action :locate_collection, only: [:index, :edit]
	before_action :authenticate_user!

  def index
  	authorize(:digital_asset, :index?)
  	@digital_asset = DigitalAsset.new
  end

  def create
  	authorize(:digital_asset, :create?)
		begin
      ApplicationRecord.transaction do
  	  	digital_asset_secret = DigitalAssetSecret.new(asset_file_name: digital_asset_params[:asset_name], asset_url: digital_asset_params[:asset_url])
  	  	raise SyException, digital_asset_secret.errors.full_messages.first unless digital_asset_secret.save(validate: false)
  	  	@digital_asset =  digital_asset_secret.create_digital_asset(digital_asset_params)
  	  	raise SyException, @digital_asset.errors.full_messages.first unless @digital_asset.errors.empty?
    		flash[:success] = "Asset has been successfully created."
      end
		rescue SyException => e
			flash[:error] = e.message
		end
  	redirect_to collection_digital_assets_path(@collection)
  end

  def update
  	authorize @digital_asset
  	if @digital_asset.update(digital_asset_params) && @digital_asset.errors.empty?
  		flash[:success] = "Asset has been successfully updated."
  	else
  		flash[:error] =  @digital_asset.errors.full_messages.first
  	end
  	redirect_to collection_digital_assets_path(@collection)
  end

  def edit
  	authorize @digital_asset
  end

  def destroy
  	authorize @digital_asset
  	if @digital_asset.destroy
  		flash[:success] = "Asset has been successfully deleted."
  	else
  		flash[:error] = @digital_asset.errors.full_messages.first
  	end
  	redirect_back(fallback_location: proc { collection_digital_assets_path(@collection) })
  end

  private
  def set_collection
  	@collection = Collection.find_by_id(params[:collection_id])
  end

  def set_digital_asset
  	@digital_asset = DigitalAsset.find_by_id(params[:id])
  end

  def digital_asset_params
  	params.require(:digital_asset).permit(:asset_name, :asset_description, :asset_url, :published_on, :expires_at, :language, :collection_id)
  end

  def locate_collection
  	@digital_assets = DigitalAssetPolicy::Scope.new(current_user, DigitalAsset).resolve(filtering_params).page(params[:page]).per(params[:per_page]).includes(digital_assets: [:digital_asset_secret])
  end

  def filtering_params
  	 params.slice(:asset_name, :id, :language, :collection_id)
  end
end
