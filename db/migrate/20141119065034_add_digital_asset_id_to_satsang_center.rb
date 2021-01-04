class AddDigitalAssetIdToSatsangCenter < ActiveRecord::Migration
  def change
    add_column :satsang_centers, :digital_asset_id, :integer, :references => [:digital_assets, :id]
  end
end
