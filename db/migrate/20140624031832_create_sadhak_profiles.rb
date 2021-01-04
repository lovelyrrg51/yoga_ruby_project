class CreateSadhakProfiles < ActiveRecord::Migration
  def change
    create_table :sadhak_profiles do |t|
      t.string :syid
      t.string :first_name
      t.string :last_name
      t.string :middle_name
      t.string :gender
      t.string :marital_status
      t.integer :faith
      t.boolean :any_legal_proceedings
      t.boolean :attended_any_shivir
      t.integer :photo_id_proof
      t.integer :address_proof
      t.integer :user_id
      t.string :status
      t.timestamps
    end
  end
end
