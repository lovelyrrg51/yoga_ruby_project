class CreatePurchasedDigitalAssets < ActiveRecord::Migration
  def change
    create_table :purchased_digital_assets do |t|
      t.integer :digital_asset_id
      t.integer :user_id
      t.string  :promo_code_used
      t.timestamps
    end
  end
end
