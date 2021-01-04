class AddAssetToDigitalAsset < ActiveRecord::Migration
  def change
  	  add_attachment :digital_assets, :asset
  	  add_attachment :digital_assets, :thumbnail_image
  end
end
