class AddIndexesToPurchasedDigitalAsset < ActiveRecord::Migration
  def change
    add_index :purchased_digital_assets, :digital_asset_id
    add_index :purchased_digital_assets, :promo_code_used
  end
end
