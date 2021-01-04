class CreateSadhakStoreProfiles < ActiveRecord::Migration
  def change
    create_table :sadhak_store_profiles do |t|
      t.string :prefered_currency
      t.string :default_shipping_address_id
      t.string :default_billing_address_id
      t.integer :sadhak_profile_id
      t.timestamps
    end
  end
end
