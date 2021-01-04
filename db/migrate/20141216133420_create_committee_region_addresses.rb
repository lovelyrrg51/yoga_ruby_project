class CreateCommitteeRegionAddresses < ActiveRecord::Migration
  def change
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
