class CreateEventTypeDigitalAssetAssociations < ActiveRecord::Migration
  def change
    create_table :event_type_digital_asset_associations do |t|
      t.references :event_type, index: true
      t.references :digital_asset, index: true
      t.foreign_key :event_types
      t.foreign_key :digital_assets

      t.timestamps
    end
  end
end
