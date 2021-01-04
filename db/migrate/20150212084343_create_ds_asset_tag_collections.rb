class CreateDsAssetTagCollections < ActiveRecord::Migration
  def change
    create_table :ds_asset_tag_collections do |t|
      t.string :name
      t.references :ds_asset_tag, index: true
      t.foreign_key :ds_asset_tags
      t.timestamps
    end
  end
end
