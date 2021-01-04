class ChangeColumnTypeAssetFileSizeToBigIntDigitalAssetSecret < ActiveRecord::Migration[5.1]
  def change
    change_column :digital_asset_secrets, :asset_file_size, :bigint
  end
end
