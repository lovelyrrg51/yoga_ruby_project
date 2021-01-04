class ChangeColumnTypeOfAssetFileSizeInDigitalAssetSecret < ActiveRecord::Migration[5.1]
  def change
    change_column :digital_asset_secrets, :asset_file_size, :integer, limit: 8
  end
end
