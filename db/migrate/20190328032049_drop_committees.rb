class DropCommittees < ActiveRecord::Migration[5.2]
  def up
    remove_column :ds_shops, :committee_id
    remove_column :tickets, :committee_id
    remove_column :events, :committee_id

    drop_table :committee_sadhak_profile_associations
    drop_table :committee_region_addresses
    drop_table :committees
  end

  def down
    add_column :ds_shops, :committee_id, :integer
    add_column :tickets, :committee_id, :integer
    add_column :events, :committee_id, :integer

    create_table :committees do |t|
      t.string :name
      t.integer :reporting_committee_id
      t.integer :committee_level
      t.references :sadhak_profile, index: true
      t.foreign_key :sadhak_profiles, column: :sadhak_profile_id
      t.timestamps
    end

    create_table :committee_sadhak_profile_associations do |t|
      t.integer :committee_id
      t.integer :sadhak_profile_id

      t.timestamps
    end

    create_table :committee_region_addresses do |t|
      t.integer :country_id
      t.integer :state_id
      t.integer :city_id
      t.string :postal_code
      t.string :locality_name
      t.references :committee
      t.foreign_key :committees, column: :committee_id

      t.timestamps
    end
  end
end
