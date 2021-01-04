class AddIndexToDigitalAssetSecret < ActiveRecord::Migration
  def change
    add_index :digital_asset_secrets, :digital_asset_id
  end
end
