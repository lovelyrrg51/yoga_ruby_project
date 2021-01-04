class ChangeColumnNameInSadhakProfile < ActiveRecord::Migration
  def change
    rename_column :sadhak_profiles, :is_profile_photo_approved, :profile_photo_status
    rename_column :sadhak_profiles, :is_photo_id_approved, :photo_id_status
    rename_column :sadhak_profiles, :is_address_proof_approved, :address_proof_status
  end
end
