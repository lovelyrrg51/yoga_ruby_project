class AddColumnToSadhakProfile < ActiveRecord::Migration
  def change
    add_column :sadhak_profiles, :profile_photo_status, :integer
    add_column :sadhak_profiles, :photo_id_status, :integer
    add_column :sadhak_profiles, :address_proof_status, :integer
  end
end
