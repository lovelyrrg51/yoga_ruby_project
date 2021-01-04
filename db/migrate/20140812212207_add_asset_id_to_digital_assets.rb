class AddAssetIdToDigitalAssets < ActiveRecord::Migration
  def change
    add_column :digital_assets, :video_id, :string
    add_column :digital_assets, :is_owned, :boolean
  end
end
