class AddAssetFileSizeToDigitalAssetSecret < ActiveRecord::Migration
  def change
    add_column :digital_asset_secrets, :asset_file_size, :integer
  end
end
