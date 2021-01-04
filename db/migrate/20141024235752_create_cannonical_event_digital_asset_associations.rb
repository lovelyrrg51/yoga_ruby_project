class CreateCannonicalEventDigitalAssetAssociations < ActiveRecord::Migration
  def change
    create_table :cannonical_event_digital_asset_associations do |t|
      t.integer :cannonical_event_id
      t.integer :digital_asset_id
      t.timestamps
    end
  end
end
