class CreateOtherSpiritualAssociations < ActiveRecord::Migration
  def change
    create_table :other_spiritual_associations do |t|
      t.string :organization_name
      t.string :association_description
      t.integer :associated_since_year
      t.integer :associated_since_month
      t.integer :duration_of_practice
      t.integer :sadhak_profile_id
      t.timestamps
    end
  end
end
