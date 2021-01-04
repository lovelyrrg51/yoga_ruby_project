class CreateEventDigitalAssetAssociations < ActiveRecord::Migration
  def change
    create_table :event_digital_asset_associations do |t|
      t.references :event, index: true
      t.references :digital_asset, index: true
      t.foreign_key :events
      t.foreign_key :digital_assets

      t.timestamps
    end
  end
end
