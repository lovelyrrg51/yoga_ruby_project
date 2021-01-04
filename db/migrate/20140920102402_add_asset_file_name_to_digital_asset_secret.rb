class AddAssetFileNameToDigitalAssetSecret < ActiveRecord::Migration
  def change
    add_column :digital_asset_secrets, :asset_file_name, :string
  end
end
