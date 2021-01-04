class AddDeletedAtToDigitalAssetSecret < ActiveRecord::Migration
  def change
    add_column :digital_asset_secrets, :deleted_at, :datetime
    add_index :digital_asset_secrets, :deleted_at
  end
end
