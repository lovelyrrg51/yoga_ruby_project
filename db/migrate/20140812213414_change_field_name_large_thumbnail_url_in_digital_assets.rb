class ChangeFieldNameLargeThumbnailUrlInDigitalAssets < ActiveRecord::Migration
  def change
    add_column :digital_assets, :asset_large_thumbnail_url, :string 
    remove_column :digital_assets, :asset_large_thubnail_url
  end
end
