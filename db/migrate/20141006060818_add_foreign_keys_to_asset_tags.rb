class AddForeignKeysToAssetTags < ActiveRecord::Migration
  def up
    execute <<-SQL
    ALTER TABLE asset_tags
        ADD CONSTRAINT fk_asset_tags_tag_collections
        FOREIGN KEY (tag_collection_id)
        REFERENCES tag_collections(id)
    SQL
  end
  def down
  	execute <<-SQL
        ALTER TABLE asset_tags
        DROP CONSTRAINT fk_asset_tags_tag_collections
    SQL
  end
end
