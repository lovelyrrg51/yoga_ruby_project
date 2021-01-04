class CreateAdvanceProfiles < ActiveRecord::Migration
  def change
    create_table :advance_profiles do |t|
      t.string :faith
      t.boolean :any_legal_proceeding
      t.boolean :attended_any_shivir
      t.string :photograph_url
      t.string :photograph_path
      t.string :photo_id_proof_type
      t.string :photo_id_proof_number
      t.string :photo_id_proof_url
      t.string :photo_id_proof_path
      t.string :address_proof_type
      t.string :address_proof_url
      t.string :address_proof_path
      t.integer :sadhak_profile_id
      
      t.timestamps
    end
  end
end
