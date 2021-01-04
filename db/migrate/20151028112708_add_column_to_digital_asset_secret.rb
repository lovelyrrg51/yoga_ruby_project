class AddColumnToDigitalAssetSecret < ActiveRecord::Migration
  def change
    add_column :digital_asset_secrets, :asset_url, :string
  end
end
