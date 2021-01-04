class AddColumnsToSadhakProfile < ActiveRecord::Migration
  def change
    add_column :sadhak_profiles, :is_profile_photo_approved, :boolean,
    :default => false
    add_column :sadhak_profiles, :is_photo_id_approved, :boolean,
    :default => false
    add_column :sadhak_profiles, :is_address_proof_approved, :boolean,
    :default => false
  end
end
