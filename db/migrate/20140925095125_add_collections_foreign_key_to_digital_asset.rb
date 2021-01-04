class AddCollectionsForeignKeyToDigitalAsset < ActiveRecord::Migration
  def up
	  execute <<-SQL
      ALTER TABLE digital_assets
        ADD CONSTRAINT fk_digital_assets_collections
        FOREIGN KEY (collection_id)
        REFERENCES collections(id)
        ON DELETE SET NULL ;
    SQL
  end
  def down
  	execute <<-SQL
      ALTER TABLE digital_assets
        DROP CONSTRAINT fk_digital_assets_collections
    SQL
  end
end
