class ChangeColumnTypeAssetFileSizeDigitalAsset < ActiveRecord::Migration[5.1]
  def change
    change_column :digital_assets, :asset_file_size, :integer, limit: 8
  end
end
