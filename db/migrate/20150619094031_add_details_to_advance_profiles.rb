class AddDetailsToAdvanceProfiles < ActiveRecord::Migration
  def change
    add_column :advance_profiles, :address_proof_type_id, :integer
    add_column :advance_profiles, :photo_id_proof_type_id, :integer
  end
end
