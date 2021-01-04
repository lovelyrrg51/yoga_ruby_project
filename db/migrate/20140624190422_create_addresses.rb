class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :first_line
      t.string :second_line
      t.string :city
      t.string :district
      t.string :state
      t.string :postal_code
      t.string :country
      t.string :address_type
      t.integer :sadhak_profile_id
      t.timestamps
    end
  end
end
