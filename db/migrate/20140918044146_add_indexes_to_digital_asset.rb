class AddIndexesToDigitalAsset < ActiveRecord::Migration
  def change
    add_index :digital_assets, :asset_name
    add_index :digital_assets, :author
  end
end
