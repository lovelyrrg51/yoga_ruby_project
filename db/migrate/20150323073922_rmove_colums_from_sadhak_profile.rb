class RmoveColumsFromSadhakProfile < ActiveRecord::Migration
  def change
    remove_column :sadhak_profiles, :profile_photo_status
    remove_column :sadhak_profiles, :photo_id_status
    remove_column :sadhak_profiles, :address_proof_status
  end
end
