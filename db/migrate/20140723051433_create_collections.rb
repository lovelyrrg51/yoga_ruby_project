class CreateCollections < ActiveRecord::Migration
  def change
    create_table :collections do |t|
      t.string :collection_thumbnail_url
      t.date :collection_expiry_date
      t.integer :digital_asset_id
      t.timestamps
    end
  end
end
