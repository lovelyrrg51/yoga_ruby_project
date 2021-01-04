class RemoveAddressIdFromEventAndSadhakProfile < ActiveRecord::Migration
  def change
    remove_column :events, :address_id
    remove_column :sadhak_profiles, :address_id
  end
end
