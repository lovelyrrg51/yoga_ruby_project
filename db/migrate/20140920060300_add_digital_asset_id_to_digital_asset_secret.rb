class AddDigitalAssetIdToDigitalAssetSecret < ActiveRecord::Migration
  def change
    add_column :digital_asset_secrets, :digital_asset_id, :integer
  end
end
