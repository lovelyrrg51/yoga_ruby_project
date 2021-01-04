class CreateAssetTagMappings < ActiveRecord::Migration
  def change
    create_table :asset_tag_mappings do |t|
      t.integer :digital_asset_id, :null => false, :references => [:digital_assets, :id]
      t.integer :asset_tag_id, :null => false, :references => [:asset_tags, :id]

      t.timestamps
    end
    add_index :asset_tag_mappings, [:digital_asset_id, :asset_tag_id], :unique => true
  end
end
