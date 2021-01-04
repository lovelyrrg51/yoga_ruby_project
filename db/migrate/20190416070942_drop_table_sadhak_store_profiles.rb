class DropTableSadhakStoreProfiles < ActiveRecord::Migration[5.2]
  def up
    drop_table :sadhak_store_profiles
  end

  def down
    create_table :sadhak_store_profiles do |t|
      t.string :prefered_currency
      t.string :default_shipping_address_id
      t.string :default_billing_address_id
      t.integer :sadhak_profile_id
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :sadhak_store_profiles, :deleted_at, name: "index_sadhak_store_profiles_on_deleted_at"
  end
end
