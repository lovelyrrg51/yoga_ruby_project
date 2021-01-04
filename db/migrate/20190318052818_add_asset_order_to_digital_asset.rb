class AddAssetOrderToDigitalAsset < ActiveRecord::Migration[5.1]
  def change
    add_column :digital_assets, :asset_order, :integer, default: 0
  end
end
