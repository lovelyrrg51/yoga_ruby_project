class AddFieldsToDigitalAssetSecret < ActiveRecord::Migration
  def change
    add_column :digital_asset_secrets, :asset_hls_url, :string
    add_column :digital_asset_secrets, :asset_sd_url, :string
    add_column :digital_asset_secrets, :asset_mobile_url, :string
  end
end
