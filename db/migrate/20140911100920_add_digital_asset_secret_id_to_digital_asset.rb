class AddDigitalAssetSecretIdToDigitalAsset < ActiveRecord::Migration
  def change
    add_column :digital_assets, :digital_asset_secret_id, :integer
  end
end
