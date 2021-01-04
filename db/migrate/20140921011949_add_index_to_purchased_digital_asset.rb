class AddIndexToPurchasedDigitalAsset < ActiveRecord::Migration
  def change
    add_index :purchased_digital_assets, :user_id
  end
end
